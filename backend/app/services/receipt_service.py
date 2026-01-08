"""Receipt verification service for App Store and Play Store"""
from typing import Optional, Dict, Any
from app.config import settings
import httpx
import json
import base64


class ReceiptService:
    """Service for verifying App Store and Play Store receipts"""
    
    # Apple App Store verification URLs
    APPLE_SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt"
    APPLE_PRODUCTION_URL = "https://buy.itunes.apple.com/verifyReceipt"
    
    # Google Play verification URL
    GOOGLE_VERIFY_URL = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications"
    
    async def verify_apple_receipt(
        self,
        receipt_data: str,
        app_account_token: str
    ) -> Dict[str, Any]:
        """
        Verify Apple App Store receipt
        
        Args:
            receipt_data: Base64-encoded receipt data
            app_account_token: App account token (UUID)
            
        Returns:
            Dict with subscription status and details
        """
        # Determine which URL to use
        url = (
            self.APPLE_PRODUCTION_URL
            if settings.apple_environment == "production"
            else self.APPLE_SANDBOX_URL
        )
        
        payload = {
            "receipt-data": receipt_data,
            "password": settings.apple_shared_secret,  # Shared secret
            "exclude-old-transactions": True,
        }
        
        async with httpx.AsyncClient() as client:
            try:
                response = await client.post(url, json=payload, timeout=10.0)
                response.raise_for_status()
                result = response.json()
                
                # Handle Apple's response
                if result.get("status") == 0:
                    # Receipt is valid
                    # Parse the latest_receipt_info to get subscription details
                    latest_receipt_info = result.get("latest_receipt_info", [])
                    if latest_receipt_info:
                        latest = latest_receipt_info[-1]  # Get most recent
                        return {
                            "valid": True,
                            "product_id": latest.get("product_id"),
                            "original_transaction_id": latest.get("original_transaction_id"),
                            "expires_at": self._parse_apple_date(latest.get("expires_date_ms")),
                            "status": "active" if self._is_apple_active(latest) else "expired",
                        }
                    return {"valid": False, "error": "No receipt info found"}
                else:
                    # Receipt is invalid
                    return {"valid": False, "error": f"Apple status: {result.get('status')}"}
                    
            except httpx.RequestError as e:
                return {"valid": False, "error": f"Request failed: {str(e)}"}
    
    async def verify_google_receipt(
        self,
        purchase_token: str,
        product_id: str,
        app_account_token: str
    ) -> Dict[str, Any]:
        """
        Verify Google Play Store purchase
        
        Args:
            purchase_token: Purchase token from Google Play
            product_id: Product ID (subscription ID)
            app_account_token: App account token (UUID)
            
        Returns:
            Dict with subscription status and details
        """
        if not settings.google_package_name:
            return {
                "valid": False,
                "error": "Google Play verification not configured (missing GOOGLE_PACKAGE_NAME)"
            }
        
        # Google Play API requires service account authentication
        # This is a simplified implementation - full implementation requires:
        # 1. Service account JSON key file
        # 2. Google Play Developer API enabled
        # 3. Proper OAuth2 authentication
        
        try:
            from google.oauth2 import service_account
            from googleapiclient.discovery import build
            from googleapiclient.errors import HttpError
            import os
            
            # Check if service account file exists
            if not settings.google_service_account_path or not os.path.exists(settings.google_service_account_path):
                return {
                    "valid": False,
                    "error": "Google Play service account file not found. Please configure GOOGLE_SERVICE_ACCOUNT_PATH."
                }
            
            # Load service account credentials
            credentials = service_account.Credentials.from_service_account_file(
                settings.google_service_account_path,
                scopes=['https://www.googleapis.com/auth/androidpublisher']
            )
            
            # Build the API client
            service = build('androidpublisher', 'v3', credentials=credentials)
            
            # Verify the purchase
            try:
                subscription = service.purchases().subscriptions().get(
                    packageName=settings.google_package_name,
                    subscriptionId=product_id,
                    token=purchase_token
                ).execute()
                
                # Parse subscription status
                # Google Play returns: 0=active, 1=cancelled, 2=expired, etc.
                payment_state = subscription.get('paymentState', 0)
                expiry_time_millis = subscription.get('expiryTimeMillis')
                
                # Determine status
                if payment_state == 1:  # Payment received
                    status = "active"
                elif payment_state == 0:  # Payment pending
                    status = "active"  # Still active, just pending payment
                else:
                    status = "expired"
                
                # Parse expiration date
                expires_at = None
                if expiry_time_millis:
                    from datetime import datetime
                    timestamp = int(expiry_time_millis) / 1000
                    expires_at = datetime.fromtimestamp(timestamp).isoformat()
                
                # Check if subscription is still valid
                is_active = status == "active"
                if expires_at:
                    from datetime import datetime
                    expires_dt = datetime.fromisoformat(expires_at.replace('Z', '+00:00'))
                    is_active = is_active and expires_dt > datetime.now()
                
                return {
                    "valid": is_active,
                    "product_id": product_id,  # Return the product_id that was verified
                    "purchase_token": purchase_token,
                    "expires_at": expires_at,
                    "status": "active" if is_active else "expired",
                }
                
            except HttpError as e:
                # Handle API errors
                error_details = e.error_details[0] if e.error_details else {}
                error_reason = error_details.get('reason', 'unknown')
                
                if error_reason == 'subscriptionNotFound':
                    return {
                        "valid": False,
                        "error": "Subscription not found or invalid purchase token"
                    }
                elif error_reason == 'invalidToken':
                    return {
                        "valid": False,
                        "error": "Invalid purchase token"
                    }
                else:
                    return {
                        "valid": False,
                        "error": f"Google Play API error: {error_reason}"
                    }
                    
        except ImportError:
            return {
                "valid": False,
                "error": "Google Play API libraries not installed. Install: pip install google-auth google-auth-oauthlib google-auth-httplib2 google-api-python-client"
            }
        except Exception as e:
            return {
                "valid": False,
                "error": f"Google Play verification failed: {str(e)}"
            }
    
    def _parse_apple_date(self, expires_date_ms: Optional[str]) -> Optional[str]:
        """Parse Apple's timestamp (milliseconds since epoch) to ISO format"""
        if not expires_date_ms:
            return None
        try:
            from datetime import datetime
            timestamp = int(expires_date_ms) / 1000
            return datetime.fromtimestamp(timestamp).isoformat()
        except (ValueError, TypeError):
            return None
    
    def _is_apple_active(self, receipt_info: Dict[str, Any]) -> bool:
        """Check if Apple subscription is currently active"""
        expires_date_ms = receipt_info.get("expires_date_ms")
        if not expires_date_ms:
            return False
        
        try:
            from datetime import datetime
            timestamp = int(expires_date_ms) / 1000
            expires_at = datetime.fromtimestamp(timestamp)
            return expires_at > datetime.now()
        except (ValueError, TypeError):
            return False

receipt_service = ReceiptService()
