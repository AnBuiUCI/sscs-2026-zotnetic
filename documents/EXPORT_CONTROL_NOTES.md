# Export control form: draft answers for review

`Export_Control_GF_Rev8.2.pdf` is GLOBALFOUNDRIES' export-control questionnaire
(the `.docx` next to it is the editable source it was exported from),
required by the SSCS Chipathon organizers before the **11 November 2026**
reservation deadline of the January GF shuttle. It is linked from `info.yaml`
(`project.export_control`). PDF is accepted: several teams the organizers
already confirmed (A63, C01, D03) submitted theirs as PDF.

**Status: DRAFT, NOT SIGNED.** The answers were pre-filled by the team from the
technical facts of the design. Legal classifications (ECCN, jurisdiction) and
the signature belong to someone **authorized to bind the University of
California** (the faculty advisor and/or the UCI export-control office). GF may
contact the signer directly.

Every field marked `[TO BE CONFIRMED BY THE SIGNER]` or written in `[brackets]`
needs attention before signing.

## What the chip is (facts behind the answers)

- Academic research and educational test chip, GF180MCU 180 nm CMOS, 5 V devices.
- Analog/mixed-signal sensor interface: four external magnetoresistive bridges
  → amplifiers, comparators, analog vote counter → three digital outputs.
- No RF/mmWave function, no encryption, no processor, no memory array, no qubits.
- Open-source design, Apache-2.0, published on GitHub.

## Answers that need a decision

| Q | Draft answer | Why / what to confirm |
|---|---|---|
| Header | Customer: UC Irvine; contact: team lead | Phone and contact person should be the signer's institutional ones |
| 4 | No (one design) | The shuttle carries many projects; this form covers only B26_A. Confirm with the organizers |
| 7 | Yes, research ASIC | It is designed for one function, but not for any commercial equipment |
| 12 | Yes, subject to the EAR | Product proposed as **EAR99**; the published open-source design proposed as publicly available technology (15 CFR 734.3(b)(3), 734.7). **The export-control office must confirm** |
| 17 | 8542.39 (other ICs) | Subheading (.0050 / .0060) to be chosen by the signer |
| 20 | UC Irvine, Irvine, CA 92697 | Add the department or laboratory address |
| 2, 3 | No | Confirm that no team member or party is on a restricted list or resident in a sanctioned region |
| Signature | blank | Name, title, organization and signature of the authorized signer |

All remaining questions (1c, 5, 6, 8–11, 13–16, 18, 19) are answered **No**, or
N/A where they only apply after a Yes, because the chip has no RF, military,
encryption, high-performance computing, memory or quantum function.

## Privacy

This repository is public. Use institutional contact details on the signed
form, not personal ones.
