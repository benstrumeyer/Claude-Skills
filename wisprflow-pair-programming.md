# VoiceMeeter + WisprFlow Pair Programming Setup

Route mic + call audio into WisprFlow for transcription, while still hearing everything through your headphones. Works with Discord, Google Meet, or any calling app.

## What You Need

- **VoiceMeeter Banana** (free)
- **Discord** and/or **Google Meet**
- **WisprFlow** (or any transcription app)
- Headphones plugged into audio jack

## How It Works

VoiceMeeter sits in the middle of all your audio:

- Your mic and call audio both get mixed into the **B1 bus**
- WisprFlow listens to B1 — so it hears both you and your partner
- Everything also gets sent to **A1** — your headphones — so you hear it all normally
- The other person never hears themselves echoed back because their audio never loops back out

---

## Step 1 — Install VoiceMeeter Banana

1. Download and install from [vb-audio.com/Voicemeeter/banana.htm](https://vb-audio.com/Voicemeeter/banana.htm)
2. **Restart your PC** after installing — this is required for the virtual audio devices to register in Windows

## Step 2 — Configure VoiceMeeter A1 Output (Your Headphones)

1. Open VoiceMeeter Banana
2. Click **A1** in the top right (Hardware Out section)
3. Select **WDM: Headphones (Realtek)** — this is your physical headphone jack
4. This makes **A1 = your ears**

## Step 3 — Set Up Your Mic (Strip 1)

1. Click **"Select Input Device"** on Stereo Input 1 (top left strip)
2. Choose your microphone from the list
3. On that strip, enable:
   - **A1** — so you can optionally hear yourself (turn off if you don't want this)
   - **B1** — so WisprFlow picks up your voice
4. Make sure both buttons are **glowing green** when enabled

## Step 4a — Configure Discord

1. Open Discord → **Settings → Voice & Video**
2. Set **Output Device** (Speaker) → `Voicemeeter Input (VB-Audio Voicemeeter VAIO)`
   - This sends your friend's voice INTO VoiceMeeter
3. Set **Input Device** (Microphone) → leave as **Windows Default**
4. **Turn off Echo Cancellation** in Discord (VoiceMeeter handles this)

## Step 4b — Configure Google Meet

1. Join or start a Google Meet call
2. Click the **three dots (⋮)** → **Settings** → **Audio**
3. Set **Speaker** → `VoiceMeeter Input (VB-Audio VoiceMeeter VAIO)`
   - This sends the other person's voice INTO VoiceMeeter
4. Set **Microphone** → your actual microphone (same one selected in VoiceMeeter Strip 1)
   - Do NOT set this to a VoiceMeeter device — that would create a feedback loop

> **Note:** Google Meet remembers these settings per browser. Set once in Chrome and it persists across calls.

> **Tip:** If VoiceMeeter devices don't appear in Meet's dropdown, make sure VoiceMeeter is running first, then refresh the Meet page.

## Step 5 — Configure the Virtual Input Strip (Call Audio)

1. In VoiceMeeter, find the **Virtual Input** strip (middle strip, says "Voicemeeter Input")
2. Enable:
   - **A1** — so you can hear the other person through your headphones
   - **B1** — so WisprFlow picks up their voice
3. Make sure A1 is NOT the only thing enabled — **B1 must also be on** for transcription to work
4. Leave A2 off — not needed

## Step 6 — Configure Windows Sound Settings

1. Go to **Windows Settings → System → Sound**
2. Set **Output device** → `VoiceMeeter Input (VB-Audio Voicemeeter VAIO)`
   - This routes Spotify, YouTube, games etc. through VoiceMeeter so they play through your headphones via A1
3. Set **Input device** → your microphone (same one selected in VoiceMeeter Strip 1)

> **Important:** Do NOT set Windows output to VB-Audio Virtual Cable or any other device — use **VoiceMeeter Input (VAIO)** only.

## Step 7 — Configure WisprFlow

1. Open WisprFlow
2. Go to microphone/input settings
3. Select **`Voicemeeter Out B1 (VB-Audio Voicemeeter VAIO)`**
4. This gives WisprFlow the mixed feed of your mic + call audio

## Step 8 — Test Everything

- **Speak** → watch Strip 1 meters move in VoiceMeeter, WisprFlow should pick up your voice
- **Have the other person speak** → watch the Virtual Input strip meters move
- **Play Spotify or YouTube** → should play through your headphones normally
- **The other person should NOT hear themselves echoed**

---

## Quick Reference

### Discord

| Setting | Value | Why |
|---------|-------|-----|
| Discord Output (Speaker) | VoiceMeeter Input (VAIO) | Sends call audio into VoiceMeeter |
| Discord Input (Mic) | Windows Default | Direct to Discord, no VoiceMeeter loop |
| Echo Cancellation | Off | VoiceMeeter handles this |

### Google Meet

| Setting | Value | Why |
|---------|-------|-----|
| Meet Speaker | VoiceMeeter Input (VAIO) | Sends call audio into VoiceMeeter |
| Meet Microphone | Your physical microphone | Direct to Meet, no VoiceMeeter loop |

### VoiceMeeter & System

| Setting | Value | Why |
|---------|-------|-----|
| VoiceMeeter A1 | Headphones (Realtek) | Your ears |
| VoiceMeeter B1 | Virtual output bus | What WisprFlow listens to |
| Strip 1 (mic) | A1 + B1 on | You hear yourself + WisprFlow gets your voice |
| Virtual Input (call audio) | A1 + B1 on | You hear partner + WisprFlow gets their voice |
| Windows Output | VoiceMeeter Input (VAIO) | All system audio routes through VoiceMeeter |
| WisprFlow Input | Voicemeeter Out B1 | Mixed feed of mic + call |

---

## Troubleshooting

### Can't hear anything through headphones
- Check VoiceMeeter A1 is set to **Headphones (Realtek)**
- Check A1 is enabled (glowing) on the Virtual Input strip
- Check Windows output is set to **VoiceMeeter Input (VAIO)**, not Virtual Cable

### WisprFlow isn't picking up voice
- Check B1 is enabled on Strip 1 (mic) and Virtual Input strip
- Check WisprFlow input is set to **Voicemeeter Out B1**
- Make sure VoiceMeeter is actually running

### Friend hears themselves echoed (Discord)
- Make sure Discord's **Echo Cancellation is turned off**
- Do NOT set Discord's input to anything VoiceMeeter related — leave it as **Windows Default**

### Other person hears themselves echoed (Google Meet)
- Make sure Google Meet's **Microphone** is set to your **physical mic**, NOT a VoiceMeeter device
- If echo persists, check that Chrome doesn't have a different audio output set in `chrome://settings/content/sound`

### VoiceMeeter devices not showing in Google Meet
- VoiceMeeter must be running before you open the Meet page
- Refresh the Meet page after starting VoiceMeeter
- Try closing and reopening Chrome if devices still don't appear

### Spotify/YouTube not playing
- Check Windows output device is **VoiceMeeter Input (VAIO)**
- VoiceMeeter must be open and running for audio to flow

### Audio jack headphones not working
- VoiceMeeter takes control of audio devices when open
- Don't try to use the headphone jack directly — let VoiceMeeter route through it via A1
- Always set Windows output to VoiceMeeter Input, then let VoiceMeeter send it to your headphones

---

## Important Notes

- VoiceMeeter **must be running at all times** for this to work
- You can set VoiceMeeter to launch on startup: **Menu → Run on Windows Startup**
- If audio breaks after a reboot, restart VoiceMeeter first before anything else
- Google Meet remembers audio device settings per browser — set once, works for all future calls
- This works with **any calling app** that lets you pick audio devices — Zoom, Teams, Slack huddles, etc. Just set the app's speaker output to `VoiceMeeter Input (VAIO)` and its mic to your physical microphone.
