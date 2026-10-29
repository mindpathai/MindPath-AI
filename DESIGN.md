---
name: MindPath AI
description: Preliminary screening and self-support for OCD and Hoarding Disorder.
colors:
  still-water-teal: "#2F5D56"
  still-water-deep: "#1E423D"
  still-water-mist: "#DEEAE6"
  ember-clay: "#CE8463"
  ember-clay-wash: "#F6E5DA"
  quiet-sage: "#6F8E76"
  quiet-sage-wash: "#E2EBE1"
  dusk-periwinkle: "#7E90BB"
  morning-screen: "#F7F8F5"
  white-surface: "#FFFFFF"
  dove-paper: "#E9ECE7"
  dove-paper-deep: "#DFE4DE"
  forest-ink: "#1C2B27"
  moss-ink: "#42514C"
  lichen-ink: "#5F6C67"
  hairline: "#D9E0DA"
  hairline-faint: "#E8EDE8"
  edge: "#87918C"
typography:
  brand:
    fontFamily: "Fraunces, Georgia, serif"
    fontSize: "38px"
    fontWeight: 500
    lineHeight: 1.1
    letterSpacing: "-0.02em"
  display:
    fontFamily: "Fraunces, Georgia, serif"
    fontSize: "31px"
    fontWeight: 500
    lineHeight: 1.1
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Fraunces, Georgia, serif"
    fontSize: "25px"
    fontWeight: 500
    lineHeight: 1.1
    letterSpacing: "-0.02em"
  title:
    fontFamily: "Fraunces, Georgia, serif"
    fontSize: "23px"
    fontWeight: 500
    lineHeight: 1.25
    letterSpacing: "-0.015em"
  lead:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.55
  body:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 400
  small:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "13.5px"
    fontWeight: 400
  button:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 600
  caption:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "11.5px"
    fontWeight: 400
    lineHeight: 1.4
  label:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "11.5px"
    fontWeight: 600
    letterSpacing: "0.06em"
  eyebrow:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "11.5px"
    fontWeight: 600
    letterSpacing: "0.09em"
  tag:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "11.5px"
    fontWeight: 700
    letterSpacing: "0.08em"
rounded:
  swatch: "3px"
  scale-cell: "12px"
  badge: "14px"
  field: "15px"
  card: "22px"
  item: "24px"
  hero: "26px"
  pill: "999px"
spacing:
  s2: "2px"
  s3: "3px"
  s4: "4px"
  s6: "6px"
  s7: "7px"
  s8: "8px"
  s9: "9px"
  s10: "10px"
  s11: "11px"
  s12: "12px"
  s13: "13px"
  s14: "14px"
  s15: "15px"
  s16: "16px"
  s18: "18px"
  s20: "20px"
  s22: "22px"
  s24: "24px"
  s26: "26px"
  s30: "30px"
  s38: "38px"
components:
  button-primary:
    backgroundColor: "{colors.still-water-teal}"
    textColor: "{colors.white-surface}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    padding: "12px 18px"
  button-primary-disabled:
    backgroundColor: "{colors.hairline-faint}"
    textColor: "{colors.lichen-ink}"
  button-submit:
    backgroundColor: "{colors.still-water-teal}"
    textColor: "{colors.white-surface}"
    rounded: "{rounded.pill}"
    padding: "16px 0"
    width: "100%"
  button-light:
    backgroundColor: "{colors.white-surface}"
    textColor: "{colors.still-water-teal}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    padding: "12px 20px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.forest-ink}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    padding: "12px 18px"
  chip-sos:
    backgroundColor: "{colors.ember-clay-wash}"
    textColor: "{colors.forest-ink}"
    typography: "{typography.tag}"
    rounded: "{rounded.pill}"
    padding: "6px 12px"
  card:
    backgroundColor: "{colors.white-surface}"
    rounded: "{rounded.card}"
    padding: "16px"
  card-hero:
    backgroundColor: "{colors.still-water-teal}"
    textColor: "{colors.white-surface}"
    rounded: "{rounded.hero}"
    padding: "20px"
  input-field:
    backgroundColor: "{colors.morning-screen}"
    textColor: "{colors.forest-ink}"
    rounded: "{rounded.field}"
    padding: "13px 15px"
  badge:
    backgroundColor: "{colors.still-water-mist}"
    textColor: "{colors.still-water-teal}"
    rounded: "{rounded.badge}"
    size: "44px"
  nav-bar:
    backgroundColor: "{colors.white-surface}"
    rounded: "{rounded.hero}"
    height: "66px"
  nav-tab-active:
    backgroundColor: "{colors.still-water-mist}"
    textColor: "{colors.still-water-teal}"
    rounded: "{rounded.pill}"
    width: "42px"
    height: "28px"
---

# Design System: MindPath AI

## Overview

**Creative North Star: "The Settling Ripple"**

MindPath AI is built around the moment after a disturbance, when the water goes still again. Someone arrives worried that something might be wrong. The interface doesn't reflect that agitation back at them. It takes it in and lets it settle. Concentric arcs are the visible form of this idea: they rise in the logo mark, spread outward on the check-in hero, and come back in the result chart. Everything else stays still enough for those arcs to carry the meaning.

The mood is gentle, grounded and honest. Gentle: muted greens and earth tones on a pale, slightly green-tinted screen, with warm Fraunces serif headlines that read as a person speaking, not a clinic. Grounded: one spacing scale, one motion curve, one shadow, one main action per screen. Nothing improvised. Honest: progress is always visible, results come with their level and limits, and warmth is never used to blur what a number means.

The interface is designed for a single phone column (390 × 812 reference, max content width 440px). Screens are sparse on purpose. A typical screen has a greeting or question in Fraunces, two or three white cards, and one solid teal pill. Light mode only for now: `themeMode` is fixed to light. Dark values exist in `docs/mindpath-screens.html` but are not implemented in the app.

**Key Characteristics:**
- Concentric arcs are the only brand motif (logo, hero ripple, result chart).
- Pale sage screen with white cards, hairline borders, and almost no shadow.
- Fraunces for human moments, Hanken Grotesk for everything functional.
- One dominant action per screen; tactile press feedback, never loud.
- No red, no badges, no counters, no breakable streaks.

## Colors

A muted, nature-drawn palette: one deep teal-green carries the action, one warm clay replaces every alarm colour, and a sage and a periwinkle add quiet secondary meaning. Everything sits on pale, slightly green-tinted greys.

### Primary
- **Still-Water Teal** (`still-water-teal`): the single action colour. Solid pill buttons, focused field borders, cursor, checkbox fill, active nav icon and label, link text, the logo mark. If something on screen is teal, it is either the action or the brand.
- **Still-Water Deep** (`still-water-deep`): only as the dark end of the hero card's 145° gradient (teal → deep). Never a standalone fill.
- **Still-Water Mist** (`still-water-mist`): tinted backgrounds for teal-toned items: the active nav pill, pine-tone icon badges, Material `primaryContainer`.

### Secondary
- **Ember Clay** (`ember-clay`): attention without alarm. The fill of "High" level tags (Ember Clay Wash) and their swatches, error borders and the error-line icon, and the offset square behind the logo (at 28% opacity). It replaces red everywhere.
- **Ember Clay Wash** (`ember-clay-wash`): the background of the SOS chip (with Forest Ink text) and clay-tone badges.

### Tertiary
- **Quiet Sage** (`quiet-sage`): positive and settled states. The selected mood face, "strong" password strength, met password rules, sage-tone badges.
- **Quiet Sage Wash** (`quiet-sage-wash`): the sage badge background.
- **Dusk Periwinkle** (`dusk-periwinkle`): used once, for "fair" password strength. A cool in-between step, not a general accent.

### Neutral
- **Morning Screen** (`morning-screen`): the scaffold background of every screen, and the fill inside text fields.
- **White Surface** (`white-surface`): cards, the floating nav, the light pill, and text on teal.
- **Dove Paper / Dove Paper Deep** (`dove-paper`, `dove-paper-deep`): the backdrop of the design rail in the mockup document. Not used inside app screens.
- **Forest Ink** (`forest-ink`): primary text, and the tint for all shadows.
- **Moss Ink** (`moss-ink`): secondary text, leads under titles, app-bar icons, error-message text.
- **Lichen Ink** (`lichen-ink`): captions, eyebrows, field labels, inactive nav, disabled text. The quietest text step, and still readable: 4.6:1 or more on every surface it sits on.
- **Edge** (`edge`): the outline of a control whose edge is its only cue: text-field borders and unchecked checkboxes. 3:1 on the screen and on white. Material's `outline` role.
- **Hairline** (`hairline`): ghost-pill borders, mood-face and scale-cell outlines, the note rule. Decorative or backed by a label, so it can stay light. Material's `outlineVariant` role.
- **Hairline Faint** (`hairline-faint`): card borders, the nav border, progress track, disabled pill fill.

### Named Rules
**The No-Red Rule.** Red does not exist in this app. Errors, high levels and the SOS chip use the Ember Clay family. Alarm colours feed exactly the anxiety the product is trying to settle.

**The Closed Palette Rule.** `lib/theme/app_colors.dart` holds every colour the app may use. A new colour needs a role in this document first. Opacity variants of existing tokens (the 7% ambient circles, the 78% white hero subtext) are the only allowed derivations.

**The Ink-Not-Grey Rule.** Shadows and tints come from Forest Ink, never neutral grey or black.

**The Readable Ink Rule.** Every piece of readable text meets WCAG AA: 4.5:1 against its background, including the 7% ambient tints. The three ink steps (Forest 13.8:1, Moss 7.8:1, Lichen 5.2:1 on Morning Screen) keep their order; quiet means a lighter step, never an unreadable one. Moss and Lichen are darker than the original mockup (`#5E6E68`, `#93A09A`) for this reason, and the app values win.

**The Visible Edge Rule.** An outline that is the only thing showing where a control is (a text field, an unchecked checkbox) uses Edge at 3:1. An outline beside a label, icon or number that already identifies the control may stay Hairline.

## Typography

**Display Font:** Fraunces (with Georgia, serif)
**Body Font:** Hanken Grotesk (with system-ui, sans-serif)

**Character:** Fraunces at weight 500 with slightly tight tracking is the voice of a person: warm, a little literary, never clinical. Hanken Grotesk is the steady working hand underneath, used for labels, body text, buttons and numbers. The contrast between the two tells the user who is speaking: the app as a companion, or the app as a tool.

### Hierarchy
- **Brand** (500, 38px, 1.1): the MindPath AI name on the sign-in and welcome screens only.
- **Display** (500, 31px, 1.1): greetings ("Good evening, …").
- **Headline** (500, 25px, 1.1): result headlines and screen titles such as "You are not alone".
- **Title** (500, 23px, 1.25, −0.015em): card headlines and task questions ("Start your check-in", "Imagine it is in front of you right now.").
- **Lead** (400, 15px, 1.55): the explanatory sentence under a headline, and long-form text in cards. 15px/500 is the text typed into a field; 15px/700 is emphasis.
- **Body** (400 / 600, 14px): standard text; 600 for row titles. Button labels are 14px/600 (15px/600 on full-width submits).
- **Small** (400 / 600 / 700, 13.5px): card captions, links, secondary rows, the app-bar title (700).
- **Caption** (400, 11.5px, 1.4, Lichen Ink): footnotes, notes, timing lines.
- **Label / Eyebrow / Tag** (600–700, 11.5px, uppercase, 0.05–0.09em tracking): field labels (0.06em), date and section eyebrows (0.09em), SOS and level tags (0.08em / 0.05em). Text is upper-cased at the call site.

### Named Rules
**The Eight Sizes Rule.** Only 38, 31, 25, 23, 15, 14, 13.5 and 11.5 exist. Nothing in between. Material's `TextTheme` is mapped onto these so stock widgets stay on the scale.

**The Who's-Speaking Rule.** Fraunces is for greetings, questions and result headlines: moments where the app speaks to the person. Labels, data, buttons and numbers are always Hanken Grotesk.

## Layout

Single column, phone-first. Content is centred in a column no wider than 440px (`ContentWidth`), with a 20px side gutter (`ScreenScroll`). When content is shorter than the viewport, the closing footer or note is pushed to the bottom. Screens with the floating nav reserve extra bottom space so nothing hides behind it.

Spacing comes from a named pixel scale (2–38px) taken from the mockup. Recurring rhythms: 18px between a top bar and the headline, 8px between a headline and its lead, 14–16px between stacked cards, 16px card padding (20px on the hero), and 30px before a form's first field. Tap targets are never under 48px. Small visible elements such as the SOS chip and text links sit inside a 48px-tall hit area.

**The One-Action Rule.** Every screen has exactly one dominant action: one solid teal pill, or the light pill on the hero. Everything else is ghost, link, or card tap.

**The Always-Visible Progress Rule.** Any multi-step task shows "Item X of Y" and the time remaining under a 5px progress bar. The user never wonders how much is left.

## Elevation & Depth

Flat, with one thing floating. Surfaces sit flat on the Morning Screen, separated by tone (white on near-white) and 1px Hairline Faint borders. Cards carry no shadow. The single shadow is kept for what is physically lifted off the page: the floating nav bar, and the sorting-task item card the user is deciding about. Two very faint ambient circles (a 300px teal circle off the top-right, a 230px clay circle off the left edge, both at 7%) add a sense of depth behind the content without adding objects.

### Shadow Vocabulary
- **Soft float** (`0 18px 40px -22px rgba(28,43,39,.45), 0 2px 6px -2px rgba(28,43,39,.10)`): the floating nav bar and the sorting-task item card. In Flutter, the blur is converted to sigma (33.8 and 4.3). Nothing else.

### Named Rules
**The One-Shadow Rule.** There is one shadow, tinted with Forest Ink. If a new element seems to need depth, it is either floating (and gets this shadow) or it isn't (and gets a hairline border).

## Shapes

Soft, generous rounding that grows with importance. Pills (999px) for every button, chip and the active nav marker. Hero card, logo mark and floating nav use the largest radius (26px). Cards are 22px, the sorting item card is 24px, fields 15px, badges 14px, scale cells 12px, legend swatches 3px. Borders are always 1px hairlines, or 1.5px for outlines that signal interaction (ghost pill, focused field, checkbox). Icons are stroke-only line glyphs (1.6 stroke, round caps and joins) drawn from SVG paths in `line_icon.dart`. No filled icon sets.

The logo mark's silhouette is a teal rounded square with a clay-tinted square offset 13px behind it, down and to the right. That is the one deliberate overlap in the system.

## Components

The feel is tactile but restrained. You can feel every press (a 120ms scale to 0.97), but nothing shouts. One teal pill per screen; everything else is quiet.

### Buttons
- **Shape:** full pill (999px), never a rectangle.
- **Primary (solid):** Still-Water Teal fill, white 14px/600 label, padding 12px 18px. The full-width submit variant uses 15px/600 and 16px vertical padding.
- **Light:** white fill, teal label. Only on the teal hero card.
- **Ghost:** transparent with a 1.5px Hairline border and Forest Ink label.
- **States:** press scales to 0.97 over 120ms. Disabled becomes Hairline Faint fill with Lichen Ink text. Loading keeps the normal fill and swaps the label for a 17px spinner via a 240ms cross-fade. An optional trailing arrow glyph sits 7px after the label.
- **Link:** teal 13.5px/600 text, stadium-shaped ink, 48px minimum tap area.

### Chips
- **SOS chip:** Ember Clay Wash pill with Forest Ink uppercase tag text "SOS" (Ember Clay text on the wash is only about 2.3:1), padding 6px 12px, inside a 48px tap area. It sits under the avatar in the home header and is announced as "SOS, get help now". This is the only chip.
- **Level tags:** uppercase 11.5px/700 Forest Ink text on a tone wash (teal, clay or sage) for High / Medium / Low on results. The wash and the swatch beside the row carry the tone; the text stays ink, because clay and sage text on their washes fall below 4.5:1.

### Cards / Containers
- **Corner Style:** 22px.
- **Background:** White Surface.
- **Shadow Strategy:** none (see Elevation).
- **Border:** 1px Hairline Faint.
- **Internal Padding:** 16px. Tappable cards use the same 0.97 press scale plus a Material ink ripple.
- **Row card:** icon badge, title and caption, trailing chevron. Used for condition areas and list rows.

### Inputs / Fields
- **Style:** Morning Screen fill, 1px Edge border, 15px radius, padding 13px 15px. The uppercase Lichen Ink label always floats inside the box (no notched outline).
- **Focus:** border becomes 1.5px Still-Water Teal; teal cursor.
- **Error:** 1px Ember Clay border (1.5px when focused). The message below uses a small clay info icon with Moss Ink text, because clay is too light to read at caption size. Fields stay quiet until first blurred, then validate on every change.
- **Password:** obscured with 3px letter-spacing, and a Lichen Ink eye / eye-off toggle.

### Navigation
- **Floating nav:** a white bar 66px tall, 26px radius, 1px Hairline Faint border, the soft float shadow. It is inset 14px from the sides and 16px from the bottom, and capped at 440px wide.
- **Tabs:** line icon over a 11.5px/600 label. Inactive is Lichen Ink. Active is Still-Water Teal with the icon on a 42×28 Still-Water Mist pill. Colour and pill animate over 240ms ease-out-cubic.
- **No badges or counters,** ever.
- **Top bar:** back chevron, centred 13.5px/700 title, optional trailing action, on a transparent background.

### Icon Badge
A 44px rounded square (14px radius) holding a line icon. It uses one of three tone pairs: teal (mist / teal), clay (wash / clay), sage (wash / sage). It is the leading element of row cards and quick actions.

### Check-in Hero (signature)
A teal-to-deep 145° gradient card with 26px radius and 20px padding. A Fraunces 23px white headline sits over a 78%-white 13.5px subtext and a light pill ("Begin" with an arrow). The ripple motif bleeds off its top-right corner (right −56, top −46). It is the most saturated object in the app and the home screen's single dominant action.

### Ambient Background (signature)
Every screen sits on Morning Screen with two faint circles: teal (300px, 7%) off the top-right and clay (230px, 7%) off the left edge. Either can be turned off per screen. This is depth without objects.

### Mood Strip
Five faces from "Very low" to "Great". The selected face scales to 1.08 and turns Quiet Sage, and its label turns Forest Ink (sage text is too light at caption size); the others stay Lichen Ink on Hairline.

### Task Progress
A 5px bar on a Hairline Faint track, with "Item X of Y" and the time remaining underneath. It always appears on multi-step tasks.

### Note
Small Lichen Ink caption text with a 2px Hairline rule on its left. Used for reassurances and footnotes ("There is no right answer…", "Helplines … coming soon").

## Do's and Don'ts

### Do:
- **Do** take every colour, size, gap and radius from `lib/theme/` (`AppColors`, `AppTypography`, `AppSpace`, `AppRadius`, `AppSizes`, `AppShadows`, `AppMotion`). These files say "use only these" for a reason.
- **Do** give each screen exactly one solid Still-Water Teal pill (or the light pill on the hero).
- **Do** use the single motion pairing: 240ms `easeOutCubic` for state changes, 120ms press to 0.97 for touch. No bounce, no spring.
- **Do** show "Item X of Y" and time remaining on every multi-step task.
- **Do** use Fraunces only where the app speaks to the person (greetings, questions, result headlines).
- **Do** keep tap targets at 48px or more, even when the visible element is smaller.
- **Do** reuse the concentric-arc motif for brand moments instead of inventing new ornament.

### Don't:
- **Don't** use red anywhere. Errors, high levels and SOS use the Ember Clay family.
- **Don't** add notification badges or counters. They feed checking compulsions.
- **Don't** show a streak that can reset to zero. Count check-ins instead.
- **Don't** add shadows to cards. The soft float is only for the nav bar and the sorting item card.
- **Don't** introduce type sizes outside 38 / 31 / 25 / 23 / 15 / 14 / 13.5 / 11.5.
- **Don't** set readable text in Ember Clay or Quiet Sage at caption size, including on their washes. Pair the tone with Forest Ink or Moss Ink text instead.
- **Don't** use filled or third-party icon sets. Icons are 1.6-stroke line glyphs from `line_icon.dart`.
- **Don't** place more than one dominant action on a screen.
