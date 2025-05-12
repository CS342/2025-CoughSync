<!--

This source file is part of the CoughSync based on the Stanford Spezi Template Application project

SPDX-FileCopyrightText: 2025 Stanford University

SPDX-License-Identifier: MIT

-->

# CoughSync

[![Build and Test](https://github.com/CS342/2025-CoughSync/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/CS342/2025-CoughSync/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/CS342/2025-CoughSync/graph/badge.svg?token=ScRESP8x1r)](https://codecov.io/gh/CS342/2025-CoughSync)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14740621.svg)](https://doi.org/10.5281/zenodo.14740621)


This repository contains the CoughSync application.
CoughSync is using the [Spezi](https://github.com/StanfordSpezi/Spezi) ecosystem and builds on top of the [Stanford Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication). It was built as part of the [Stanford Biodesign](https://biodesign.stanford.edu) Building for Digital Health course in collaboration with [Regeneron Development Innovation](https://www.regeneron.com/).

> [!TIP]
> Do you want to test the CoughSync application on your device? [You can download it on TestFlight](https://testflight.apple.com/join/2DKsMx2z).

## Background

- *Clinical Challenge*: Chronic cough in diseases like COPD disrupts sleep and reduces quality of life. Patients struggle to remember symptoms, and validated instruments are imprecise, making clinical use of current cough measures impractical.

- *Need for Objective Data*: Subjective PROs (patient-reported outcomes) limit clinical accuracy. Objective digital biomarkers may more-reliably capture physiological data for both better clinical care, and better clinical trials

- *Digital Biomarker Opportunity*: Smartphones with microphones and on-device AI/ML can passively detect coughs, addressing recall issues and supporting patient-centered data collection.


## CoughSync Features

CoughSync is designed with simplicity in mind. We want users to gain valuable insights into their cough patterns with minimal effort. Our goal is to provide meaningful data while keeping the experience seamless and non-intrusive.

To achieve this, CoughSync focuses on three core features:

### Cough Detection

CoughSync leverages a custom-built time series cough detection model to track bedtime coughing using machine learning. The detected cough events are securely stored in Firebase for seamless and persistent data access.

### Quality of Life Feedback

Beyond just numbers, CoughSync integrates medically inspired questionnaires to assess the impact of coughing on daily life. Users provide feedback during onboarding and then once a week, ensuring a holistic view of their condition. This data is securely stored in Firebase.

### Cough Report

Users can visualize their cough trends through interactive daily, weekly, and monthly graphs. The app also allows easy data export, enabling users to share their insights with healthcare professionals.
<table>
  <tr>
    <td>
      <div align="center">
        <img src="https://raw.githubusercontent.com/CS342/2025-CoughSync/main/Resources/Summary.png?raw=true" width="250"/>
        <p><strong>Summary (Light)</strong></p>
      </div>
    </td>
    <td>
      <div align="center">
        <img src="https://raw.githubusercontent.com/CS342/2025-CoughSync/main/Resources/Summary-dark.png?raw=true" width="250"/>
        <p><strong>Summary (Dark)</strong></p>
      </div>
    </td>
  </tr>
  <tr>
    <td>
      <div align="center">
        <img src="https://raw.githubusercontent.com/CS342/2025-CoughSync/main/Resources/Check%20In.png?raw=true" width="250"/>
        <p><strong>Check In (Light)</strong></p>
      </div>
    </td>
    <td>
      <div align="center">
        <img src="https://raw.githubusercontent.com/CS342/2025-CoughSync/main/Resources/Check%20in-dark.png?raw=true" width="250"/>
        <p><strong>Check In (Dark)</strong></p>
      </div>
    </td>
  </tr>
  <tr>
    <td>
      <div align="center">
        <img src="https://raw.githubusercontent.com/CS342/2025-CoughSync/main/Resources/Report.png?raw=true" width="250"/>
        <p><strong>Report (Light)</strong></p>
      </div>
    </td>
    <td>
      <div align="center">
        <img src="https://raw.githubusercontent.com/CS342/2025-CoughSync/main/Resources/Report-dark.png?raw=true" width="250"/>
        <p><strong>Report (Dark)</strong></p>
      </div>
    </td>
  </tr>
  <tr>
    <td>
      <div align="center">
        <img src="https://raw.githubusercontent.com/CS342/2025-CoughSync/main/Resources/Report2.png?raw=true" width="250"/>
        <p><strong>Detailed Report (Light)</strong></p>
      </div>
    </td>
    <td>
      <div align="center">
        <img src="https://raw.githubusercontent.com/CS342/2025-CoughSync/main/Resources/Report2-dark.png?raw=true" width="250"/>
        <p><strong>Detailed Report (Dark)</strong></p>
      </div>
    </td>
  </tr>
</table>

> [!NOTE]  
> Do you want to learn more about the Stanford Spezi Template Application and how to use, extend, and modify this application? Check out the [Stanford Spezi Template Application documentation](https://stanfordspezi.github.io/SpeziTemplateApplication)


## Contributing

Contributions to this project are welcome. A full list of contributors can be found in [CONTRIBUTORS.md](CONTRIBUTORS.md). Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
