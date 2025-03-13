<!--

This source file is part of the CoughSync based on the Stanford Spezi Template Application project

SPDX-FileCopyrightText: 2025 Stanford University

SPDX-License-Identifier: MIT

-->

# CoughSync

[![Beta Deployment](https://github.com/CS342/2025-CoughSync/actions/workflows/beta-deployment.yml/badge.svg)](https://github.com/CS342/2025-CoughSync/actions/workflows/beta-deployment.yml)
[![codecov](https://codecov.io/gh/CS342/2025-CoughSync/graph/badge.svg?token=ScRESP8x1r)](https://codecov.io/gh/CS342/2025-CoughSync)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14740621.svg)](https://doi.org/10.5281/zenodo.14740621)


This repository contains the CoughSync application.
CoughSync is using the [Spezi](https://github.com/StanfordSpezi/Spezi) ecosystem and builds on top of the [Stanford Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication).

> [!TIP]
> Do you want to test the CoughSync application on your device? [You can downloard it on TestFlight](https://testflight.apple.com/join/2DKsMx2z).


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
        <img src="https://github.com/CS342/2025-CoughSync/blob/documentation/Resources/Report2.png?raw=true" width="250"/>
        <p><strong>Summary</strong></p>
      </div>
    </td>
    <td>
      <div align="center">
        <img src="https://raw.githubusercontent.com/CS342/2025-CoughSync/main/Resources/Check In.png" width="250"/>
        <p><strong>Check In</strong></p>
      </div>
    </td>
  </tr>
  <tr>
    <td>
      <div align="center">
        <img src="https://raw.githubusercontent.com/CS342/2025-CoughSync/main/Resources/Report.png" width="250"/>
        <p><strong>Report</strong></p>
      </div>
    </td>
    <td>
      <div align="center">
        <img src="https://raw.githubusercontent.com/CS342/2025-CoughSync/main/Resources/Report2.png" width="250"/>
        <p><strong>Detailed Report</strong></p>
      </div>
    </td>
  </tr>
</table>



*Provide a comprehensive description of your application, including figures showing the application. You can learn more on how to structure a README in the [Stanford Spezi Documentation Guide](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/documentation-guide)*

> [!NOTE]  
> Do you want to learn more about the Stanford Spezi Template Application and how to use, extend, and modify this application? Check out the [Stanford Spezi Template Application documentation](https://stanfordspezi.github.io/SpeziTemplateApplication)


## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
