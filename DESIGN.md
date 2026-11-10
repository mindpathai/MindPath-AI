---
name: MindPath AI
description: Preliminary screening and self-support for OCD and Hoarding Disorder.
colors:
  still-water-teal: "#3C6467"
  still-water-mist: "#DDE7E5"
  ember-clay: "#A5665A"
  ember-clay-wash: "#F3E4DE"
  quiet-sage: "#6E7F5C"
  quiet-sage-wash: "#E4E8D9"
  earth-sand: "#8A7A60"
  earth-sand-wash: "#ECE5D8"
  morning-screen: "#F6F2EA"
  warm-surface: "#FCFAF5"
  on-teal: "#FFFFFF"
  dove-paper: "#EDE8DD"
  dove-paper-deep: "#E4DED1"
  forest-ink: "#25302C"
  moss-ink: "#46524C"
  lichen-ink: "#5E6862"
  hairline: "#DEDBD0"
  hairline-faint: "#ECE8DE"
  edge: "#878B83"
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
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.55
  body:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 400
    lineHeight: 1.45
  small:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "14.5px"
    fontWeight: 400
    lineHeight: 1.45
  button:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 600
  caption:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 400
    lineHeight: 1.45
  label:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "12.5px"
    fontWeight: 600
    letterSpacing: "0.05em"
  eyebrow:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "12.5px"
    fontWeight: 600
    letterSpacing: "0.08em"
  tag:
    fontFamily: "Hanken Grotesk, system-ui, sans-serif"
    fontSize: "12.5px"
    fontWeight: 700
    letterSpacing: "0.06em"
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
    textColor: "{colors.on-teal}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    padding: "12px 18px"
  button-primary-disabled:
    backgroundColor: "{colors.hairline-faint}"
    textColor: "{colors.lichen-ink}"
  button-submit:
    backgroundColor: "{colors.still-water-teal}"
    textColor: "{colors.on-teal}"
    rounded: "{rounded.pill}"
    padding: "16px 0"
    width: "100%"
  button-light:
    backgroundColor: "{colors.warm-surface}"
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
    backgroundColor: "{colors.warm-surface}"
    rounded: "{rounded.card}"
    padding: "16px"
  card-hero:
    backgroundColor: "{colors.still-water-teal}"
    textColor: "{colors.on-teal}"
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
    backgroundColor: "{colors.warm-surface}"
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

The mood is gentle, grounded and honest. Gentle: a muted teal and a muted sage on a warm off-white screen, with warm Fraunces serif headlines that read as a person speaking, not a clinic. Grounded: one spacing scale, one motion curve, one shadow, one main action per screen. Nothing improvised. Honest: progress is always visible, results come with their level and limits, and warmth is never used to blur what a number means.

The interface is designed for a single phone column (390 × 812 reference, max content width 440px). Screens are sparse on purpose. A typical screen has a greeting or question in Fraunces, two or three warm off-white cards, and one solid teal pill. Light mode only for now: `themeMode` is fixed to light. Dark values exist in `docs/mindpath-screens.html` but are not implemented in the app.

**Key Characteristics:**
- Concentric arcs are the only brand motif (logo, hero ripple, result chart).
- Warm off-white screen with lighter warm cards, hairline borders, and almost no shadow. No gradients.
- Fraunces for human moments, Hanken Grotesk for everything functional.
- One dominant action per screen; tactile press feedback, never loud.
- No red, no badges, no counters, no breakable streaks.

## Why this palette and layout (research rationale)

These choices are deliberate, made for the people this app serves: adults worried about OCD or hoarding, often anxious when they open it. Each one is checked in code or tests, so it cannot drift silently.

| Decision | Reason | Where it is enforced |
|---|---|---|
| **De-saturated teal, sage and earth tones** as the whole palette | Low-saturation, cool-to-neutral colours are rated as calmer and less arousing than saturated ones; high saturation raises arousal. Many users arrive in a heightened state. | `lib/theme/app_colors.dart`, Closed Palette Rule |
| **No red, no bright orange.** One muted terracotta (Ember Clay) only for real alerts: the SOS chip and field errors | Red and orange read as threat and warning. A screening result, even a high one, is information, not danger; showing it in an alarm colour would feed the anxiety the app is trying to settle. Results and the weak-password bar use teal, sage and sand instead. | `Tone` has no clay (`lib/widgets/icon_badge.dart`); Alert-Only Clay Rule |
| **Soft contrast:** dark grey-green ink on warm off-white, never pure black on pure white | Maximum contrast causes glare and visual fatigue on phone screens; warm off-white with dark grey keeps text easy to read while staying WCAG AA (4.5:1 or more). | `test/contrast_test.dart` |
| **Fixed, predictable layout.** Back is always top-left, the tab bar never moves, each screen starts with the same top bar | Uncertainty and "did I do that right?" doubt are core OCD experiences. A layout that never changes position removes one source of checking and second-guessing. | `ScreenTopBar` on every non-tab screen; `FloatingNavBar` in the shell |
| **One clear main action per screen, generous space, minimal clutter** | Fewer choices lower decision load. For hoarding in particular, a cluttered screen would mirror the very problem the person is struggling with. | One-Action Rule |
| **Calm, slow motion** (320ms ease-in-out, no slide or zoom between screens, a 0.98 press) | Sudden movement pulls attention and can startle. Screens fade rather than slide, so nothing sweeps across the view. The phone's reduce-motion setting turns motion off. | `AppMotion`, `CalmFadeTransitionsBuilder` |
| **Larger type** (body 15-16px, nothing readable under 12.5px) | Reading is harder under stress, and many users in Pakistan read English as a second language. Sizes also scale with the phone's text-size setting. | `AppTypography`, large-text test in `test/hardening_test.dart` |
| **Plain, everyday wording** ("Log in", "Start", "Log out", "Type password again"; no "Submit", "Authenticate", "Sync") | Users may be non-technical. Every label should be understood at first glance, without guessing. | Plain Words Rule |
| **No badges, counters or breakable streaks** | Counters and streaks invite checking and fear of "breaking" something, which feed OCD-style loops. | Do's and Don'ts |

## Colors

Two muted, desaturated anchors: a blue-green teal carries the action and a sage green carries positive and settled states. A quiet earth sand covers low and in-between states. One muted terracotta is the only alert colour. Everything sits on warm off-whites, never stark white, and every fill is flat.

### Primary
- **Still-Water Teal** (`still-water-teal`): the single action colour. Solid pill buttons, focused field borders, cursor, checkbox fill, active nav icon and label, link text, the logo mark. If something on screen is teal, it is either the action or the brand.
- **Still-Water Mist** (`still-water-mist`): tinted backgrounds for teal-toned items: the active nav pill, pine-tone icon badges, Material `primaryContainer`.

### Secondary
- **Ember Clay** (`ember-clay`): a muted terracotta, the only alert colour. Reserved for the SOS chip, field-error borders and the error-line icon. The one brand exception is the offset square behind the logo mark, at 28% opacity, which matches the official logo. It replaces red everywhere, and is never a primary, background or result colour.
- **Ember Clay Wash** (`ember-clay-wash`): the background of the SOS chip (with Forest Ink text).

### Tertiary
- **Quiet Sage** (`quiet-sage`): the second anchor, for positive and settled states. The selected mood face, "okay" password strength, met password rules, "Medium" result levels, sage-tone badges, the ambient circle behind content, and the sorting-task art.
- **Quiet Sage Wash** (`quiet-sage-wash`): the sage badge background and the sorting-task art circle.
- **Earth Sand** (`earth-sand`): a quiet earth tone for "Low" result levels and the "weak" password bar. Neutral on purpose: it informs without warning.
- **Earth Sand Wash** (`earth-sand-wash`): the sand level-tag and badge background.

### Neutral
- **Morning Screen** (`morning-screen`): the scaffold background of every screen, and the fill inside text fields.
- **Warm Surface** (`warm-surface`): cards, the floating nav and the light pill. A warm off-white, one step lighter than the screen.
- **On Teal** (`on-teal`): text and strokes on teal fills. The only pure white in the app.
- **Dove Paper / Dove Paper Deep** (`dove-paper`, `dove-paper-deep`): the backdrop of the design rail in the mockup document. Not used inside app screens.
- **Forest Ink** (`forest-ink`): primary text, and the tint for all shadows.
- **Moss Ink** (`moss-ink`): secondary text, leads under titles, app-bar icons, error-message text.
- **Lichen Ink** (`lichen-ink`): captions, eyebrows, field labels, inactive nav, disabled text. The quietest text step, and still readable: 4.5:1 or more on every surface it sits on.
- **Edge** (`edge`): the outline of a control whose edge is its only cue: text-field borders and unchecked checkboxes. 3:1 on the screen and on cards. Material's `outline` role.
- **Hairline** (`hairline`): ghost-pill borders, mood-face and scale-cell outlines, the note rule. Decorative or backed by a label, so it can stay light. Material's `outlineVariant` role.
- **Hairline Faint** (`hairline-faint`): card borders, the nav border, progress track, disabled pill fill.

### Named Rules
**The No-Red Rule.** Red and bright orange do not exist in this app. Alarm colours feed exactly the anxiety the product is trying to settle.

**The Alert-Only Clay Rule.** Ember Clay marks something the user must act on now (SOS, a field error) and nothing else. Results, levels, badges and the password meter never use it: "High" is shown in teal, "Medium" in sage, "Low" in sand. `Tone` has no clay value, so it cannot be picked by mistake.

**The Flat Fill Rule.** There are no gradients in the app. Every fill is one flat token.

**The Closed Palette Rule.** `lib/theme/app_colors.dart` holds every colour the app may use. A new colour needs a role in this document first. Opacity variants of existing tokens (the 7% ambient circles, the 78% white hero subtext) are the only allowed derivations.

**The Ink-Not-Grey Rule.** Shadows and tints come from Forest Ink, never neutral grey or black.

**The Readable Ink Rule.** Every piece of readable text meets WCAG AA: 4.5:1 against its background, including the 7% ambient tints. The three ink steps (Forest 12.2:1, Moss 7.3:1, Lichen 5.2:1 on Morning Screen) keep their order; quiet means a lighter step, never an unreadable one. `test/contrast_test.dart` checks these pairs, so a colour change that breaks one fails the tests.

**The Visible Edge Rule.** An outline that is the only thing showing where a control is (a text field, an unchecked checkbox) uses Edge at 3:1. An outline beside a label, icon or number that already identifies the control may stay Hairline.

## Typography

**Display Font:** Fraunces (with Georgia, serif)
**Body Font:** Hanken Grotesk (with system-ui, sans-serif)

**Character:** Fraunces at weight 500 with slightly tight tracking is the voice of a person: warm, a little literary, never clinical. Hanken Grotesk is the steady working hand underneath, used for labels, body text, buttons and numbers. The contrast between the two tells the user who is speaking: the app as a companion, or the app as a tool.

### Hierarchy
- **Brand** (500, 38px, 1.1): the MindPath AI name on the sign-in and welcome screens only.
- **Display** (500, 31px, 1.1): greetings ("Good evening, …").
- **Headline** (500, 25px, 1.1): result headlines and screen titles such as "You are not alone".
- **Title** (500, 23px, 1.25, −0.015em): card headlines and task questions ("Answer a few questions", "Imagine it is in front of you right now.").
- **Lead** (400, 16px, 1.55): the explanatory sentence under a headline, and long-form text in cards. 16px/500 is the text typed into a field; 16px/700 is emphasis.
- **Body** (400 / 600, 15px): standard text; 600 for row titles. Button labels are 15px/600 (16px/600 on full-width submits).
- **Small** (400 / 600 / 700, 14.5px): card captions, links, secondary rows, the app-bar title (700).
- **Caption** (400, 13px, 1.45, Lichen Ink): footnotes, notes, timing lines, tab labels.
- **Label / Eyebrow / Tag** (600–700, 12.5px, uppercase, 0.04–0.08em tracking): field labels (0.05em), date and section eyebrows (0.08em), SOS and level tags (0.06em / 0.04em). Text is upper-cased at the call site.

### Named Rules
**The Nine Sizes Rule.** Only 38, 31, 25, 23, 16, 15, 14.5, 13 and 12.5 exist. Nothing in between, and nothing readable below 12.5. Material's `TextTheme` is mapped onto these so stock widgets stay on the scale.

**The Who's-Speaking Rule.** Fraunces is for greetings, questions and result headlines: moments where the app speaks to the person. Labels, data, buttons and numbers are always Hanken Grotesk.

## Layout

Single column, phone-first. Content is centred in a column no wider than 440px (`ContentWidth`), with a 20px side gutter (`ScreenScroll`). When content is shorter than the viewport, the closing footer or note is pushed to the bottom. Screens with the floating nav reserve extra bottom space so nothing hides behind it.

Spacing comes from a named pixel scale (2–38px) taken from the mockup. Recurring rhythms: 18px between a top bar and the headline, 8px between a headline and its lead, 14–16px between stacked cards, 16px card padding (20px on the hero), and 30px before a form's first field. Tap targets are never under 48px. Small visible elements such as the SOS chip and text links sit inside a 48px-tall hit area.

**The Fixed-Frame Rule.** Every screen outside the tab bar starts with the same top bar: Back at top left (48px), title centred. Tab screens keep the floating bar in the same place. Nothing about where to go back or where the tabs are ever changes between screens.

**The Plain Words Rule.** Labels use everyday words a non-technical person understands instantly: "Log in", "Log out", "Start", "Next", "Save", "Type password again". Never "Submit", "Authenticate", "Sync", "Sign out" next to "Log in", or a word that needs a dictionary. Error messages say what to do ("Please enter a valid email address"), not what went wrong in system terms.

**The One-Action Rule.** Every screen has exactly one dominant action: one solid teal pill, or the light pill on the hero. Everything else is ghost, link, or card tap. On the Dashboard the dominant action moves: the mood faces lead until one is picked, then the questions card turns teal.

**The Next-Step Rule.** The Dashboard reads top to bottom in the order a person uses it. Each section carries a numbered step label, and the strongest colour sits on the step to do next. A step guides; it never locks the steps after it.

**The Always-Visible Progress Rule.** Any multi-step task shows "Item X of Y" and the time remaining under a 5px progress bar. The user never wonders how much is left.

## Elevation & Depth

Flat, with one thing floating. Surfaces sit flat on the Morning Screen, separated by tone (warm surface on warm screen) and 1px Hairline Faint borders. Cards carry no shadow. The single shadow is kept for what is physically lifted off the page: the floating nav bar, and the sorting-task item card the user is deciding about. Two very faint ambient circles (a 300px teal circle off the top-right, a 230px sage circle off the left edge, both at 7%) add a sense of depth behind the content without adding objects.

### Shadow Vocabulary
- **Soft float** (`0 18px 40px -22px rgba(28,43,39,.45), 0 2px 6px -2px rgba(28,43,39,.10)`): the floating nav bar and the sorting-task item card. In Flutter, the blur is converted to sigma (33.8 and 4.3). Nothing else.

### Named Rules
**The One-Shadow Rule.** There is one shadow, tinted with Forest Ink. If a new element seems to need depth, it is either floating (and gets this shadow) or it isn't (and gets a hairline border).

## Shapes

Soft, generous rounding that grows with importance. Pills (999px) for every button, chip and the active nav marker. Hero card, logo mark and floating nav use the largest radius (26px). Cards are 22px, the sorting item card is 24px, fields 15px, badges 14px, scale cells 12px, legend swatches 3px. Borders are always 1px hairlines, or 1.5px for outlines that signal interaction (ghost pill, focused field, checkbox). Icons are stroke-only line glyphs (1.6 stroke, round caps and joins) drawn from SVG paths in `line_icon.dart`. No filled icon sets.

The logo mark's silhouette is a teal rounded square with a clay-tinted square offset 13px behind it, down and to the right. That is the one deliberate overlap in the system.

## Components

The feel is tactile but restrained. You can feel every press (a 160ms scale to 0.98), but nothing shouts. One teal pill per screen; everything else is quiet.

### Buttons
- **Shape:** full pill (999px), never a rectangle.
- **Primary (solid):** Still-Water Teal fill, On Teal 14px/600 label, padding 12px 18px. The full-width submit variant uses 15px/600 and 16px vertical padding.
- **Light:** Warm Surface fill, teal label. Only on the teal hero card.
- **Ghost:** transparent with a 1.5px Hairline border and Forest Ink label.
- **States:** press scales to 0.98 over 160ms. Disabled becomes Hairline Faint fill with Lichen Ink text. Loading keeps the normal fill and swaps the label for a 17px spinner via a 320ms cross-fade, and a second tap while loading does nothing. An optional trailing arrow glyph sits 7px after the label.
- **Link:** teal 14.5px/600 text, stadium-shaped ink, 48px minimum tap area.

### Chips
- **SOS chip:** Ember Clay Wash pill with a 17px Forest Ink phone icon and Forest Ink uppercase tag text "SOS" (Ember Clay text on the wash is only about 2.9:1), padding 6px 12px, inside a 48px tap area. It sits under the avatar in the home header and is announced as "SOS, get help now". This is the only chip.
- **Level tags:** uppercase 12.5px/700 Forest Ink text on a tone wash (teal for High, sage for Medium, sand for Low) on results. Never clay. The wash and the swatch beside the row carry the tone; the text stays ink, because sage and sand text on their washes fall below 4.5:1.

### Cards / Containers
- **Corner Style:** 22px.
- **Background:** Warm Surface.
- **Shadow Strategy:** none (see Elevation).
- **Border:** 1px Hairline Faint.
- **Internal Padding:** 16px. Tappable cards use the same 0.97 press scale plus a Material ink ripple.
- **Row card:** icon badge, title and caption, trailing chevron. Used for condition areas and list rows.

### Inputs / Fields
- **Style:** Morning Screen fill, 1px Edge border, 15px radius, padding 13px 15px. The uppercase Lichen Ink label always floats inside the box (no notched outline).
- **Focus:** border becomes 1.5px Still-Water Teal; teal cursor.
- **Error:** 1px Ember Clay border (1.5px when focused). The message below uses a small clay info icon with Moss Ink text, because clay is too light to read at caption size. Fields stay quiet until first blurred, then validate on every change. The Register email field also validates once the user pauses typing for 0.7s, so a malformed address is flagged before they leave the field, without an error flashing on every keystroke. Fields stop accepting input at their maximum length (name 50, email 254, password 128).
- **Password:** obscured with 3px letter-spacing, and a Lichen Ink eye / eye-off toggle.

### Navigation
- **Floating nav:** a Warm Surface bar 66px tall, 26px radius, 1px Hairline Faint border, the soft float shadow. It is inset 14px from the sides and 16px from the bottom, and capped at 440px wide.
- **Tabs:** line icon over a 13px/600 label that shrinks to fit at very large text. Inactive is Lichen Ink. Active is Still-Water Teal with the icon on a 42×28 Still-Water Mist pill. Colour and pill animate over 320ms ease-in-out.
- **No badges or counters,** ever.
- **Top bar:** back chevron, centred 14.5px/700 title (optional where the screen's own heading names it), optional trailing action, on a transparent background. Used on every screen outside the tab bar, including Login and Register.
- **Screen changes:** the new screen fades in over 320ms (`CalmFadeTransitionsBuilder`). No sliding or zooming. iOS keeps its native transition for swipe-back.

### Icon Badge
A 44px rounded square (14px radius) holding a line icon. It uses one of three tone pairs: teal (mist / teal), sage (wash / sage), sand (wash / sand). Never clay. It is the leading element of row cards, quick actions and Dashboard section headings, so a section can be recognised without reading its heading.

### Check-in Hero (signature)
Step 2 of the Dashboard, with 26px radius and 20px padding. A pine icon badge sits above a Fraunces 23px headline, a 14.5px subtext and the "Start" pill with an arrow.

- **Quiet (no mood picked yet):** Warm Surface fill, Hairline Faint border, Forest Ink headline, Moss Ink subtext, ghost pill, no ripple.
- **Active (mood picked):** flat Still-Water Teal fill, white headline, 78%-white subtext, light pill, and the ripple motif bleeding off the top-right corner (right −56, top −46). It is the strongest object in the app and the home screen's single dominant action.

States cross-fade over 320ms, instantly under Remove animations. Start works in both states.

### Step Label
A 22px numbered circle beside an uppercase eyebrow, above each Dashboard section. The step to do next has a teal circle with white number; the others use Still-Water Mist with a teal number. Screen readers hear "Step 1, Mood check-in". The circle grows with system text size.

### Ambient Background (signature)
Every screen sits on Morning Screen with two faint circles: teal (300px, 7%) off the top-right and sage (230px, 7%) off the left edge. Either can be turned off per screen. This is depth without objects.

### Mood Strip
Five faces from "Very low" to "Great". Labels shrink to fit their cell at very large system text rather than clipping. None is selected until the user answers, so a selection always means a real answer. The selected face scales to 1.05 and turns Quiet Sage, and its label turns Forest Ink (sage text is too light at caption size); the others stay Lichen Ink on Hairline.

### Support Options
The two self-support quick actions, side by side under the mood card. They stay hidden until the user picks "Very low" or "Low", and hide again if the mood improves. Until Therapy exists, a tap reveals a note saying the exercise is coming soon.

### Task Progress
A 5px bar on a Hairline Faint track, with "Item X of Y" and the time remaining underneath. It always appears on multi-step tasks.

### Note
Small Lichen Ink caption text with a 2px Hairline rule on its left. Used for reassurances and footnotes ("There is no right answer…", "MindPath cannot answer emergencies…").

## Do's and Don'ts

### Do:
- **Do** let a long label shrink to fit at very large system text (`FittedBox` scale-down) instead of clipping it.
- **Do** take every colour, size, gap and radius from `lib/theme/` (`AppColors`, `AppTypography`, `AppSpace`, `AppRadius`, `AppSizes`, `AppShadows`, `AppMotion`). These files say "use only these" for a reason.
- **Do** give each screen exactly one solid Still-Water Teal pill (or the light pill on the hero).
- **Do** use the single motion pairing: 320ms `easeInOutCubic` for state changes, 160ms press to 0.98 for touch. No bounce, no spring, no slide between screens.
- **Do** show "Item X of Y" and time remaining on every multi-step task.
- **Do** use Fraunces only where the app speaks to the person (greetings, questions, result headlines).
- **Do** keep tap targets at 48px or more, even when the visible element is smaller.
- **Do** reuse the concentric-arc motif for brand moments instead of inventing new ornament.

### Don't:
- **Don't** use red or bright orange anywhere. Only SOS and field errors use the Ember Clay family.
- **Don't** use clay as a primary, background or result colour, and don't add gradient fills.
- **Don't** add notification badges or counters. They feed checking compulsions.
- **Don't** show a streak that can reset to zero. Count check-ins instead.
- **Don't** add shadows to cards. The soft float is only for the nav bar and the sorting item card.
- **Don't** introduce type sizes outside 38 / 31 / 25 / 23 / 16 / 15 / 14.5 / 13 / 12.5.
- **Don't** set readable text in Ember Clay, Quiet Sage or Earth Sand at caption size, including on their washes. Pair the tone with Forest Ink or Moss Ink text instead.
- **Don't** use technical or formal button words ("Submit", "Authenticate", "Sync"). Use everyday ones ("Save", "Next", "Log in", "Continue").
- **Don't** use filled or third-party icon sets. Icons are 1.6-stroke line glyphs from `line_icon.dart`.
- **Don't** place more than one dominant action on a screen.
