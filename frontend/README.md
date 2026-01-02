# FridgeGPT v1 — UI / UX Design Instruction

## 1. Overall Design Philosophy

Design a mobile app called **FridgeGPT**.

The app should feel:

- Calm
- Friendly
- Forgiving
- Slightly playful

It should **not** feel:

- Tech-heavy
- Futuristic
- Like a fitness or calorie tracker
- Overly “AI-branded”

The user is usually hungry and tired.  
The UI must reduce thinking and anxiety.

**Core design principle:**

> One obvious action per screen.  
> Everything else is secondary.

---

## 2. Color System

### Primary Color
- Soft mint green (natural, calm, food-related)
- Used for:
  - Primary buttons
  - Active navigation icon
  - Key highlights
- Avoid neon or highly saturated mint
- Prefer sage / soft mint tones

### Background Color
- Off-white with a slight warm tone
- Not pure white
- Easy on the eyes

### Text Colors
- Primary text: near-black (not pure black)
- Secondary text: medium gray
- Hint / helper text: light gray
- High contrast, but gentle

---

## 3. Typography

- Use system default fonts
  - iOS: San Francisco
  - Android: Roboto
- No custom fonts in v1

**Text tone:**
- Short
- Conversational
- Friendly

Avoid:
- ALL CAPS
- Technical language
- Long explanations

**Example tone:**
- “I might be wrong.”
- “This fridge has potential.”

---

## 4. Navigation Structure

Bottom navigation with 3 tabs:

- Home
- Scan (camera icon, visually emphasized)
- History

Notes:
- Scan is the **main action**, even though Home is default
- Settings are **not** a main tab
- Settings are accessed via a small gear icon on Home

---

## 5. Home Screen Design

**Purpose**
- Orientation
- Calm starting point

**Layout**
- Clean background
- Minimal elements

**Content**
- One short sentence at the top:
  - “What can I eat right now?”
- One large primary button:
  - 📸 Scan my fridge
- Optional (small):
  - “Last result” preview card (single item only)

**Rules**
- Do not show lists
- Do not show multiple past items
- Do not overwhelm

---

## 6. Scan Button Design (Very Important)

- Large
- Rounded rectangle or pill shape
- Solid mint color
- Contains BOTH icon and text

**Good**
- 📸 Scan my fridge

**Bad**
- Icon only
- “Start”
- Small buttons

The scan button should feel:
- Friendly
- Obvious
- Inviting

---

## 7. Scan / Camera Screen Design

**Purpose**
- Take 1–3 photos of fridge or food

**Design**
- Simple camera view
- Big shutter button
- Minimal UI

**Helper text**
- “Take 1–3 photos. Messy is okay.”

**Optional**
- “Upload from gallery” (secondary action)

No modes.  
No extra buttons.

---

## 8. Loading Screen Design

Used multiple times.

**Design**
- Simple animation (dots, shimmer, or icon)
- No progress bars
- No percentages

**Text (one sentence only)**
Examples:
- “Looking closely…”
- “Trying to make something decent.”
- “I might be wrong.”

Purpose:
- Set expectations
- Forgive mistakes

---

## 9. Ingredient Confirmation Screen

**Purpose**
- Build trust
- Let user fix AI mistakes

**Design**
- Ingredients shown as editable chips
- Rounded pill shape
- Light background
- Dark text
- Small ✕ icon to remove

**Text**
- “Here’s what I think you have.”
- “I might be wrong. Fix anything.”

**Actions**
- Remove ingredient
- Add ingredient via simple text input

No quantities.  
No units.  
No forms.

**Primary button**
- 🍳 Cook with this

---

## 10. Recipe Result Screen

**Purpose**
- Reward the user

**Layout**
- Vertical scroll
- 3 recipe cards

**Recipe types**
- Fast & Lazy
- Actually Good
- This Shouldn’t Work

**Each recipe card**
- Soft rounded corners
- Subtle shadow or border
- Food image on top
- Clear title
- Short steps (max 5–6)

**Buttons**
- Share image
- Edit ingredients
- Scan again

Avoid:
- Nutrition charts
- Calories
- Long explanations

---

## 11. History Screen

**Purpose**
- Memory only (not action)

**Design**
- Simple list
- Image thumbnail on the left
- Recipe title + time on the right

Rules:
- No scan buttons
- No call-to-action buttons
- No filters

History should feel:
> “This worked before.”

---

## 12. Settings (Hidden)

Accessed from:
- Small gear icon on Home screen

Contents:
- Clear history
- About
- Feedback
- Privacy note

Settings should feel optional and unimportant.

---

## 13. Global UI Rules

- One main action per screen
- White space is good
- Text is clearer than icons
- Calm beats clever
- Forgiving beats accurate
- Design for tired humans, not power users

---

## 14. One-Line Design Truth

> If a tired person can understand the screen in 2 seconds, the design is correct.

## App Flow Diagram

```mermaid
flowchart TD
    Start((App Launch))
    Home[Home Screen<br/>What can I eat right now?]
    Scan[Scan / Camera Screen]
    Loading1[Loading<br/>Looking closely...]
    Confirm[Ingredient Confirmation]
    Loading2[Loading<br/>Trying to make something decent]
    Result[Recipe Results<br/>3 Recipe Cards]
    History[History Screen]
    Settings[Settings]

    Start --> Home
    Home -->|Tap Scan Button| Scan
    Home -->|Tap Last Result| Result
    Home -->|Gear Icon| Settings

    Scan -->|1–3 Photos| Loading1
    Loading1 --> Confirm
    Confirm -->|Cook with this| Loading2
    Loading2 --> Result

    Result -->|Scan again| Scan
    Result -->|Edit ingredients| Confirm
    Result -->|Auto saved| History

    Home -->|Bottom Tab| History
    History -->|Tap item| Result