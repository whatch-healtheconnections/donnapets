# Design System Strategy: Donna’s Personal Pet Care

## 1. Overview & Creative North Star

### Creative North Star: "The Curated Sanctuary"
This design system rejects the "cookie-cutter" aesthetic of traditional pet service sites. Instead of loud primary colors and generic clip art, we are building a "Curated Sanctuary"—a high-end, editorial-inspired digital space that reflects the intimacy and premium nature of personalized care.

The system breaks the standard template look through **intentional asymmetry** and **tonal depth**. By utilizing oversized serif typography against a backdrop of organic, earthy hues, we create an environment that feels more like a lifestyle boutique or a high-end wellness retreat. Layouts should utilize "Breathing Room" (generous white space) and overlapping imagery to mimic the tactile feel of a luxury printed journal.

---

## 2. Colors

The palette is a sophisticated blend of mossy greens, warm clays, and cream-based surfaces.

### Tonal Hierarchy
- **Primary (`#303f15` / `#46572a`):** Use for authoritative brand moments. It represents the deep stability of nature.
- **Secondary (`#6e5a4e`):** A warm earth tone used to ground the vibrant greens.
- **Surface & Backgrounds:** We primarily utilize `surface` (`#fff8f5`) and `surface_container` variants to define space.

### The "No-Line" Rule
**Explicit Instruction:** Do not use 1px solid borders to separate sections. Structure must be achieved through background shifts. For example, a card component using `surface_container_lowest` should sit atop a `surface_container_low` section. This creates a soft, sophisticated transition that feels architectural rather than "designed."

### The "Glass & Gradient" Rule
To add visual "soul," use subtle gradients on primary CTAs, transitioning from `primary` (`#303f15`) to `primary_container` (`#46572a`). For floating navigation bars or overlays, implement **Glassmorphism**: use `surface` with 70% opacity and a `backdrop-blur` of 12px-16px to let the background textures bleed through.

---

## 3. Typography

The typographic strategy balances the authority of a clean serif with the approachability of a modern geometric sans-serif.

*   **Display & Headlines (Noto Serif):** Our "Editorial Voice." The serif reflects the personal, high-quality "Donna" brand name. Use `display-lg` for hero statements to create immediate prestige.
*   **Body & Titles (Plus Jakarta Sans):** Our "Functional Voice." A modern, highly legible sans-serif that ensures the technical details of pet care (medical notes, schedules) are clear and professional.

**Scale Philosophy:** High contrast is key. Pair a large `display-md` headline with a much smaller, tracked-out `label-md` in all caps to create an "asymmetric tension" typical of high-end magazines.

---

## 4. Elevation & Depth

We move away from the "shadow-heavy" web of the past and toward **Tonal Layering**.

### The Layering Principle
Depth is achieved by stacking the `surface-container` tokens:
1.  **Level 0 (Base):** `surface`
2.  **Level 1 (Sectioning):** `surface_container_low`
3.  **Level 2 (Cards/Content):** `surface_container_highest`

### Ambient Shadows
When an element must float (e.g., a "Book Now" modal), use an **Ambient Shadow**:
- **Color:** `on_surface` at 6% opacity.
- **Blur:** 32px to 48px.
- **Spread:** -4px.
This mimics natural light filtered through a window, rather than a harsh digital drop shadow.

### The "Ghost Border" Fallback
If a boundary is required for accessibility, use the `outline_variant` token at **15% opacity**. High-contrast, 100% opaque borders are strictly forbidden.

---

## 5. Components

### Buttons
*   **Primary:** Background: Gradient `primary` to `primary_container`. Text: `on_primary`. Shape: `full` (pill) for a soft, friendly touch.
*   **Secondary:** Background: `none`. Border: Ghost Border (15% `outline_variant`). Text: `primary`.

### Cards & Content Blocks
*   **Constraint:** No divider lines.
*   **Styling:** Use `spacing.8` (2rem) as a minimum internal padding. Content is separated by `surface` color shifts or vertical white space from the Spacing Scale. Use `xl` (1.5rem) corner radius to keep the "friendly" brand promise.

### Input Fields
*   **Style:** Minimalist. Only a bottom border (using `outline_variant` at 40%) that transitions to `primary` (2px) on focus. Labels should use `label-md` in `secondary` color.

### Signature Component: The "Pet Portrait" Card
Specifically for pet care, use a card that overlaps an image container. The image should have a `md` radius, while the text container (using `surface_container_highest`) sits slightly offset on top of the image to create an editorial, layered look.

---

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical layouts where text is left-aligned and images are right-aligned with varying margins.
*   **Do** use the `surface_tint` to provide a very subtle color wash over images to maintain brand harmony.
*   **Do** prioritize the `spacing.16` (4rem) and `spacing.24` (6rem) for section margins to allow the design to breathe.

### Don't
*   **Don't** use pure black (#000000) for text. Always use `on_surface` (`#27180f`) to keep the tone warm and organic.
*   **Don't** use "Alert" colors for non-critical information. Use `tertiary` for subtle highlights and reserve `error` strictly for functional failures.
*   **Don't** use standard 12-column grids with equal gutters. Push content slightly off-center to maintain the "Personal" feel of the brand.

---
**Director's Final Note:** Every interaction should feel like a soft touch. Use eased transitions (300ms, cubic-bezier) for all hover states and surface shifts to reinforce the concept of "Gentle, Professional Care."