# VoiceMeeter + Discord + WisprFlow Setup Guide

Route mic + Discord call audio into WisprFlow for transcription, while still hearing everything through your headphones.

## What You Need

- **VoiceMeeter Banana** (free)
- **Discord**
- **WisprFlow** (or any transcription app)
- Headphones plugged into audio jack

## How It Works

VoiceMeeter sits in the middle of all your audio:

- Your mic and Discord call audio both get mixed into the **B1 bus**
- WisprFlow listens to B1 — so it hears both you and your friend
- Everything also gets sent to **A1** — your headphones — so you hear it all normally
- Your friend never hears themselves echoed back because their audio never loops back out to Discord

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

## Step 4 — Configure Discord

1. Open Discord → **Settings → Voice & Video**
2. Set **Output Device** (Speaker) → `Voicemeeter Input (VB-Audio Voicemeeter VAIO)`
   - This sends your friend's voice INTO VoiceMeeter
3. Set **Input Device** (Microphone) → leave as **Windows Default**
4. **Turn off Echo Cancellation** in Discord (VoiceMeeter handles this)

## Step 5 — Configure the Virtual Input Strip (Discord Audio)

1. In VoiceMeeter, find the **Virtual Input** strip (middle strip, says "Voicemeeter Input")
2. Enable:
   - **A1** — so you can hear your friend through your headphones
   - **B1** — so WisprFlow picks up your friend's voice
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
4. This gives WisprFlow the mixed feed of your mic + your friend's Discord audio

## Step 8 — Test Everything

- **Speak** → watch Strip 1 meters move in VoiceMeeter, WisprFlow should pick up your voice
- **Have your friend speak** in Discord → watch the Virtual Input strip meters move
- **Play Spotify or YouTube** → should play through your headphones normally
- **Your friend should NOT hear themselves echoed** — if they do, make sure A1 is OFF on the Virtual Input strip in Discord's output, not in VoiceMeeter

---

## Quick Reference

| Setting | Value | Why |
|---------|-------|-----|
| VoiceMeeter A1 | Headphones (Realtek) | Your ears |
| VoiceMeeter B1 | Virtual output bus | What WisprFlow listens to |
| Strip 1 (mic) | A1 + B1 on | You hear yourself + WisprFlow gets your voice |
| Virtual Input (Discord) | A1 + B1 on | You hear friend + WisprFlow gets their voice |
| Discord Output | VoiceMeeter Input (VAIO) | Sends Discord audio into VoiceMeeter |
| Windows Output | VoiceMeeter Input (VAIO) | All system audio routes through VoiceMeeter |
| WisprFlow Input | Voicemeeter Out B1 | Mixed feed of mic + Discord |

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

### Friend hears themselves echoed
- Make sure Discord's **Echo Cancellation is turned off**
- Do NOT set Discord's input to anything VoiceMeeter related — leave it as **Windows Default**

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
