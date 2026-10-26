#!/usr/bin/env python3
"""Synthesizes all sound effects + a calm background music loop.
Pure numpy — no API needed. Output: 16-bit mono WAV (24 kHz)."""
import numpy as np
import wave
import os

SR = 24000
OUT = "/home/z/my-project/little_explorers/assets/audio/sfx"
MUS = "/home/z/my-project/little_explorers/assets/audio/music"
os.makedirs(OUT, exist_ok=True)
os.makedirs(MUS, exist_ok=True)


def save(name, data, folder=OUT):
    data = np.clip(data, -1.0, 1.0)
    pcm = (data * 32767).astype(np.int16)
    path = os.path.join(folder, name)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    print("wrote", path, f"{len(data)/SR:.2f}s")


def env(n, attack=0.01, release=0.3):
    """Simple attack/release envelope."""
    e = np.ones(n)
    a = int(SR * attack)
    r = int(SR * release)
    if a > 0:
        e[:a] = np.linspace(0, 1, a)
    if r > 0:
        e[-r:] *= np.linspace(1, 0, r)
    return e


def tone(freq, dur, wave_type="sine", vib=0.0):
    t = np.arange(int(SR * dur)) / SR
    ph = 2 * np.pi * freq * t
    if vib:
        ph += vib * np.sin(2 * np.pi * 6 * t)
    if wave_type == "sine":
        return np.sin(ph)
    if wave_type == "triangle":
        return 2 / np.pi * np.arcsin(np.sin(ph))
    if wave_type == "square":
        return np.sign(np.sin(ph)) * 0.5
    return np.sin(ph)


def sweep(f0, f1, dur):
    t = np.arange(int(SR * dur)) / SR
    freqs = np.linspace(f0, f1, len(t))
    ph = 2 * np.pi * np.cumsum(freqs) / SR
    return np.sin(ph)


def silence(dur):
    return np.zeros(int(SR * dur))


# ---------------- tap: soft short click ----------------
d = 0.09
x = tone(880, d) * env(int(SR * d), 0.002, 0.06) * 0.5
x += tone(1320, d) * env(int(SR * d), 0.002, 0.05) * 0.2
save("tap.wav", x)

# ---------------- pop: bubbly pop ----------------
d = 0.16
x = sweep(300, 900, d) * env(int(SR * d), 0.004, 0.1) * 0.8
pop_noise = np.random.default_rng(3).normal(0, 0.12, int(SR * 0.03))
x[: len(pop_noise)] += pop_noise * env(len(pop_noise), 0.001, 0.02)
save("pop.wav", x)

# ---------------- gentle: warm soft "try again" boop ----------------
d = 0.4
x = tone(392, d) * env(int(SR * d), 0.02, 0.25) * 0.5
x += tone(330, d, vib=0.02) * env(int(SR * d), 0.03, 0.3) * 0.35
save("gentle.wav", x)

# ---------------- star: sparkle arpeggio ----------------
notes = [1046.5, 1318.5, 1568.0]  # C6 E6 G6
x = []
for i, f in enumerate(notes):
    seg = tone(f, 0.12, vib=0.01) * env(int(SR * 0.12), 0.005, 0.08)
    x.append(seg * (0.55 - i * 0.08))
save("star.wav", np.concatenate(x))

# ---------------- success: happy major fanfare ----------------
seq = [(523.25, 0.14), (659.25, 0.14), (783.99, 0.16), (1046.5, 0.34)]
x = []
for f, dur in seq:
    seg = tone(f, dur, "triangle") * env(int(SR * dur), 0.01, 0.09)
    seg += tone(f * 2, dur) * env(int(SR * dur), 0.01, 0.07) * 0.18
    x.append(seg * 0.6)
save("success.wav", np.concatenate(x))

# ---------------- whoosh: transition sweep ----------------
d = 0.45
n = int(SR * d)
noise = np.random.default_rng(5).normal(0, 1, n)
# bandpass-ish: smooth the noise
kernel = np.ones(24) / 24
noise = np.convolve(noise, kernel, mode="same")
shape = np.sin(np.linspace(0, np.pi, n)) ** 2
x = noise * shape * 0.5
save("whoosh.wav", x)

# ---------------- unlock: magical chime ----------------
notes = [783.99, 987.77, 1174.66, 1567.98]
x = []
for i, f in enumerate(notes):
    seg = tone(f, 0.18, vib=0.015) * env(int(SR * 0.18), 0.004, 0.12)
    x.append(seg * (0.5 - i * 0.05))
tail = tone(1567.98, 0.5) * env(int(SR * 0.5), 0.004, 0.4) * 0.35
x.append(tail)
save("unlock.wav", np.concatenate(x))

# ---------------- treasure: little fanfare ----------------
seq = [(659.25, 0.12), (783.99, 0.12), (987.77, 0.14), (659.25, 0.1),
       (1046.5, 0.42)]
x = []
for f, dur in seq:
    seg = tone(f, dur, "triangle") * env(int(SR * dur), 0.01, 0.08)
    seg += tone(f / 2, dur) * env(int(SR * dur), 0.01, 0.1) * 0.2
    x.append(seg * 0.62)
save("treasure.wav", np.concatenate(x))

# ---------------- count: tiny woodblock tick ----------------
d = 0.07
n = int(SR * d)
x = sweep(1400, 900, d) * env(n, 0.001, 0.05) * 0.5
save("count.wav", x)

# ---------------- calm music loop (~48 s) ----------------
# Gentle pad progression C - G - Am - F with a soft pluck melody.
# Seamless loop: phrases built from whole bars.
bpm = 72
beat = 60 / bpm
bar = beat * 4

chords = [
    [261.63, 329.63, 392.00],   # C
    [196.00, 246.94, 392.00],   # G
    [220.00, 261.63, 329.63],   # Am
    [174.61, 220.00, 349.23],   # F
]

def pad(freqs, dur):
    n = int(SR * dur)
    t = np.arange(n) / SR
    out = np.zeros(n)
    for f in freqs:
        out += np.sin(2 * np.pi * f * t) * 0.16
        out += np.sin(2 * np.pi * f * 2 * t) * 0.03
    # slow tremolo for warmth
    out *= 1 + 0.08 * np.sin(2 * np.pi * 0.5 * t)
    # fade edges slightly inside the bar for seamless looping
    fade = int(SR * 0.05)
    out[:fade] *= np.linspace(0, 1, fade)
    out[-fade:] *= np.linspace(1, 0, fade)
    return out

def pluck(freq, dur):
    n = int(SR * dur)
    t = np.arange(n) / SR
    out = (np.sin(2 * np.pi * freq * t)
           + 0.4 * np.sin(2 * np.pi * freq * 2 * t)) * np.exp(-t * 6)
    return out * 0.22

music_bars = []
for bar_i in range(4):
    ch = chords[bar_i]
    n = int(SR * bar)
    barbuf = pad(ch, bar)
    # simple pluck pattern (root, octave, fifth, octave) mixed INTO the pad
    melody = [ch[0], ch[2], ch[1] * 2, ch[2]]
    for b in range(4):
        seg = pluck(melody[b % 4], beat)
        start = int(SR * b * beat)
        take = min(len(barbuf) - start, len(seg))
        barbuf[start:start + take] += seg[:take]
    music_bars.append(barbuf)
music = np.concatenate(music_bars)
save("peaceful_loop.wav", music, folder=MUS)

print("done")
