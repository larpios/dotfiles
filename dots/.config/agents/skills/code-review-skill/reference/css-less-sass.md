# CSS / Less / Sass Review Guide

A guide for reviewing CSS and preprocessor code, covering performance, maintainability, responsive design, and browser compatibility.

## CSS Variables vs. Hardcoding

### Scenarios where variables should be used

```css
/* ❌ Hardcoded - difficult to maintain */
.button {
  background: #3b82f6;
  border-radius: 8px;
}
.card {
  border: 1px solid #3b82f6;
  border-radius: 8px;
}

/* ✅ Using CSS Variables */
:root {
  --color-primary: #3b82f6;
  --radius-md: 8px;
}
.button {
  background: var(--color-primary);
  border-radius: var(--radius-md);
}
.card {
  border: 1px solid var(--color-primary);
  border-radius: var(--radius-md);
}
```

### Variable Naming Conventions

```css
/* Recommended variable categories */
:root {
  /* Colors */
  --color-primary: #3b82f6;
  --color-primary-hover: #2563eb;
  --color-text: #1f2937;
  --color-text-muted: #6b7280;
  --color-bg: #ffffff;
  --color-border: #e5e7eb;

  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;

  /* Typography */
  --font-size-sm: 14px;
  --font-size-base: 16px;
  --font-size-lg: 18px;
  --font-weight-normal: 400;
  --font-weight-bold: 700;

  /* Border Radius */
  --radius-sm: 4px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);

  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-normal: 300ms ease;
}
```

### Variable Scope Recommendations

```css
/* ✅ Component-level variables - reduces global pollution */
.card {
  --card-padding: var(--spacing-md);
  --card-radius: var(--radius-md);

  padding: var(--card-padding);
  border-radius: var(--card-radius);
}

/* ⚠️ Avoid frequent dynamic modification of variables via JS - impacts performance */
```

### Review Checklist

- [ ] Are color values using variables?
- [ ] Does spacing come from the design system?
- [ ] Are repeated values extracted as variables?
- [ ] Is variable naming semantic?

---

## !important Usage Guidelines

### When it can be used

```css
/* ✅ Utility classes - explicit need to override */
.hidden { display: none !important; }
.sr-only { position: absolute !important; }

/* ✅ Overriding third-party library styles (when source cannot be modified) */
.third-party-modal {
  z-index: 9999 !important;
}

/* ✅ Print styles */
@media print {
  .no-print { display: none !important; }
}
```

### When it is prohibited

```css
/* ❌ Solving specificity issues - should refactor selectors instead */
.button {
  background: blue !important;  /* Why is !important needed? */
}

/* ❌ Overriding your own styles */
.card { padding: 20px; }
.card { padding: 30px !important; }  /* Modify the original rule directly */

/* ❌ Inside component styles */
.my-component .title {
  font-size: 24px !important;  /* Breaks component encapsulation */
}
```

### Alternatives

```css
/* Problem: Need to override .btn styles */

/* ❌ Using !important */
.my-btn {
  background: red !important;
}

/* ✅ Increase specificity */
button.my-btn {
  background: red;
}

/* ✅ Use a more specific selector */
.container .my-btn {
  background: red;
}

/* ✅ Use :where() to lower the specificity of the style being overridden */
:where(.btn) {
  background: blue;  /* Specificity is 0 */
}
.my-btn {
  background: red;   /* Can be overridden normally */
}
```

### Review Comments

```markdown
🔴 [blocking] "Found 15 instances of !important, please explain the necessity of each"
🟡 [important] "This !important can be resolved by adjusting selector specificity"
💡 [suggestion] "Consider using CSS Layers (@layer) to manage style priority"
```

---

## Performance Considerations

### 🔴 High-Risk Performance Issues

#### 1. `transition: all` Issues

```css
/* ❌ Performance killer - browser checks all animatable properties */
.button {
  transition: all 0.3s ease;
}

/* ✅ Explicitly specify properties */
.button {
  transition: background-color 0.3s ease, transform 0.3s ease;
}

/* ✅ Use variables for multiple properties */
.button {
  --transition-duration: 0.3s;
  transition:
    background-color var(--transition-duration) ease,
    box-shadow var(--transition-duration) ease,
    transform var(--transition-duration) ease;
}
```

#### 2. box-shadow Animation

```css
/* ❌ Triggers repaint every frame - severely impacts performance */
.card {
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  transition: box-shadow 0.3s ease;
}
.card:hover {
  box-shadow: 0 8px 16px rgba(0,0,0,0.2);
}

/* ✅ Use pseudo-element + opacity */
.card {
  position: relative;
}
.card::after {
  content: '';
  position: absolute;
  inset: 0;
  box-shadow: 0 8px 16px rgba(0,0,0,0.2);
  opacity: 0;
  transition: opacity 0.3s ease;
  pointer-events: none;
  border-radius: inherit;
}
.card:hover::after {
  opacity: 1;
}
```

#### 3. Properties that trigger Layout (Reflow)

```css
/* ❌ Animating these properties triggers layout recalculation */
.bad-animation {
  transition: width 0.3s, height 0.3s, top 0.3s, left 0.3s, margin 0.3s;
}

/* ✅ Only animate transform and opacity (triggers Composite only) */
.good-animation {
  transition: transform 0.3s, opacity 0.3s;
}

/* Use translate instead of top/left for displacement */
.move {
  transform: translateX(100px);  /* ✅ */
  /* left: 100px; */             /* ❌ */
}

/* Use scale instead of width/height for resizing */
.grow {
  transform: scale(1.1);  /* ✅ */
  /* width: 110%; */      /* ❌ */
}
```

### 🟡 Medium Performance Issues

#### Complex Selectors

```css
/* ❌ Excessively deep nesting - slow selector matching */
.page .container .content .article .section .paragraph span {
  color: red;
}

/* ✅ Flattened */
.article-text {
  color: red;
}

/* ❌ Universal selectors */
* { box-sizing: border-box; }           /* Affects all elements */
[class*="icon-"] { display: inline; }   /* Attribute selectors are slower */

/* ✅ Limit scope */
.icon-box * { box-sizing: border-box; }
```

#### Excessive Shadows and Filters

```css
/* ⚠️ Complex shadows impact rendering performance */
.heavy-shadow {
  box-shadow:
    0 1px 2px rgba(0,0,0,0.1),
    0 2px 4px rgba(0,0,0,0.1),
    0 4px 8px rgba(0,0,0,0.1),
    0 8px 16px rgba(0,0,0,0.1),
    0 16px 32px rgba(0,0,0,0.1);  /* 5 layers of shadow */
}

/* ⚠️ Filters consume GPU */
.blur-heavy {
  filter: blur(20px) brightness(1.2) contrast(1.1);
  backdrop-filter: blur(10px);  /* Even more performance-intensive */
}
```

### Performance Optimization Suggestions

```css
/* Use will-change to hint the browser (use with caution) */
.animated-element {
  will-change: transform, opacity;
}

/* Remove will-change after animation completes */
.animated-element.idle {
  will-change: auto;
}

/* Use contain to limit repaint scope */
.card {
  contain: layout paint;  /* Tells the browser internal changes don't affect the outside */
}
```

### Review Checklist

- [ ] Is `transition: all` being used?
- [ ] Are width/height/top/left being animated?
- [ ] Is box-shadow being animated?
- [ ] Does selector nesting exceed 3 levels?
- [ ] Is there unnecessary `will-change`?

---

## Responsive Design Checkpoints

### Mobile First Principle

```css
/* ✅ Mobile First - base styles target mobile */
.container {
  padding: 16px;
  display: flex;
  flex-direction: column;
}

/* Progressive Enhancement */
@media (min-width: 768px) {
  .container {
    padding: 24px;
    flex-direction: row;
  }
}

@media (min-width: 1024px) {
  .container {
    padding: 32px;
    max-width: 1200px;
    margin: 0 auto;
  }
}

/* ❌ Desktop First - requires overriding more styles */
.container {
  max-width: 1200px;
  padding: 32px;
  flex-direction: row;
}

@media (max-width: 1023px) {
  .container {
    padding: 24px;
  }
}

@media (max-width: 767px) {
  .container {
    padding: 16px;
    flex-direction: column;
    max-width: none;
  }
}
```

### Breakpoint Recommendations

```css
/* Recommended breakpoints (based on content, not devices) */
:root {
  --breakpoint-sm: 640px;   /* Large phones */
  --breakpoint-md: 768px;   /* Tablets portrait */
  --breakpoint-lg: 1024px;  /* Tablets landscape / small laptops */
  --breakpoint-xl: 1280px;  /* Desktop */
  --breakpoint-2xl: 1536px; /* Large desktop */
}

/* Usage example */
@media (min-width: 768px) { /* md */ }
@media (min-width: 1024px) { /* lg */ }
```

### Responsive Review Checklist

- [ ] Is Mobile First adopted?
- [ ] Are breakpoints based on content breaking points rather than devices?
- [ ] Is breakpoint overlap avoided?
- [ ] Is text using relative units (rem/em)?
- [ ] Are touch targets large enough (≥44px)?
- [ ] Has orientation switching been tested?

### Common Issues

```css
/* ❌ Fixed width */
.container {
  width: 1200px;
}

/* ✅ Max-width + flexibility */
.container {
  width: 100%;
  max-width: 1200px;
  padding-inline: 16px;
}

/* ❌ Fixed height text containers */
.text-box {
  height: 100px;  /* Text might overflow */
}

/* ✅ Min-height */
.text-box {
  min-height: 100px;
}

/* ❌ Small touch targets */
.small-button {
  padding: 4px 8px;  /* Too small, hard to click */
}

/* ✅ Sufficient touch area */
.touch-button {
  min-height: 44px;
  min-width: 44px;
  padding: 12px 16px;
}
```

---

## Browser Compatibility

### Features to Check

| Feature | Compatibility | Recommendation |
|------|--------|------|
| CSS Grid | Modern Browsers ✅ | IE needs Autoprefixer + testing |
| Flexbox | Widely Supported ✅ | Legacy versions need prefixes |
| CSS Variables | Modern Browsers ✅ | Not supported in IE, needs fallback |
| `gap` (flexbox) | Newer ⚠️ | Safari 14.1+ |
| `:has()` | Newer ⚠️ | Firefox 121+ |
| `container queries` | Newer ⚠️ | Browsers after 2023 |
| `@layer` | Newer ⚠️ | Check target browsers |

### Fallback Strategies

```css
/* CSS Variable Fallback */
.button {
  background: #3b82f6;              /* Fallback value */
  background: var(--color-primary); /* Modern browsers */
}

/* Flexbox gap Fallback */
.flex-container {
  display: flex;
  gap: 16px;
}
/* Legacy browser fallback */
.flex-container > * + * {
  margin-left: 16px;
}

/* Grid Fallback */
.grid {
  display: flex;
  flex-wrap: wrap;
}
@supports (display: grid) {
  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  }
}
```

### Autoprefixer Configuration

```javascript
// postcss.config.js
module.exports = {
  plugins: [
    require('autoprefixer')({
      // Based on browserslist config
      grid: 'autoplace',  // Enable Grid prefixes (IE support)
      flexbox: 'no-2009', // Use modern flexbox syntax only
    }),
  ],
};

// package.json
{
  "browserslist": [
    "> 1%",
    "last 2 versions",
    "not dead",
    "not ie 11"  // Based on project requirements
  ]
}
```

### Review Checklist

- [ ] Has [Can I Use](https://caniuse.com) been checked?
- [ ] Do new features have fallback plans?
- [ ] Is Autoprefixer configured?
- [ ] Does browserslist meet project requirements?
- [ ] Has it been tested in target browsers?

---

## Less / Sass Specific Issues

### Nesting Depth

```scss
/* ❌ Excessively deep nesting - results in long compiled selectors */
.page {
  .container {
    .content {
      .article {
        .title {
          color: red;  // Compiles to .page .container .content .article .title
        }
      }
    }
  }
}

/* ✅ Max 3 levels */
.article {
  &__title {
    color: red;
  }

  &__content {
    p { margin-bottom: 1em; }
  }
}
```

### Mixin vs Extend vs Variables

```scss
/* Variables - for single values */
$primary-color: #3b82f6;

/* Mixin - for configurable code blocks */
@mixin button-variant($bg, $text) {
  background: $bg;
  color: $text;
  &:hover {
    background: darken($bg, 10%);
  }
}

/* Extend - for sharing identical styles (use with caution) */
%visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
}

.sr-only {
  @extend %visually-hidden;
}

/* ⚠️ Issues with @extend */
// Can produce unexpected selector combinations
// Cannot be used inside @media
// Prefer mixins
```

### Review Checklist

- [ ] Does nesting exceed 3 levels?
- [ ] Is @extend being abused?
- [ ] Are Mixins overly complex?
- [ ] Is the compiled CSS size reasonable?

---

## Quick Review Checklist

### 🔴 Must Fix

```markdown
□ transition: all
□ Animating width/height/top/left/margin
□ Excessive !important
□ Hardcoded colors/spacing repeated >3 times
□ Selector nesting >4 levels
```

### 🟡 Recommended Fix

```markdown
□ Missing responsive handling
□ Using Desktop First
□ Complex box-shadow being animated
□ Missing browser compatibility fallbacks
□ CSS variable scope is too broad
```

### 🟢 Optimization Suggestions

```markdown
□ Can use CSS Grid to simplify layout
□ Can use CSS variables to extract repeated values
□ Can use @layer to manage priority
□ Can add contain to optimize performance
```

---

## Recommended Tools

| Tool | Purpose |
|------|------|
| [Stylelint](https://stylelint.io/) | CSS Linting |
| [PurgeCSS](https://purgecss.com/) | Remove unused CSS |
| [Autoprefixer](https://autoprefixer.github.io/) | Automatic prefixing |
| [CSS Stats](https://cssstats.com/) | Analyze CSS statistics |
| [Can I Use](https://caniuse.com/) | Browser compatibility lookup |

---

## Reference Resources

- [CSS Performance Optimization - MDN](https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Performance/CSS)
- [What a CSS Code Review Might Look Like - CSS-Tricks](https://css-tricks.com/what-a-css-code-review-might-look-like/)
- [How to Animate Box-Shadow - Tobias Ahlin](https://tobiasahlin.com/blog/how-to-animate-box-shadow/)
- [Media Query Fundamentals - MDN](https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/CSS_layout/Media_queries)
- [Autoprefixer - GitHub](https://github.com/postcss/autoprefixer)
