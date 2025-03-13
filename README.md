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

The CoughSync application focuses on simplicity. We want our users to know that the application works and requires minimal effort from their end. In the end, users want to understand their cough symptoms better, but not spend a lot of time in the application.

For that purpose, our application focuses on three main features.

### Cough Detection

The application uses a bespoke time series cough detector that tracks bedtime coughing using a machine learning model under the hood. This cough data is processed and pushed to Firebase for secure persistent storage.

### Quality of Life Feedback

CoughSync not only captures the quantitivate aspects of user coughs. Instead, it takes inspiration from already existing questionnaires from medical institutions. With that, CoughSync collects quality of life data at the onboarding process and once every week. This data is then pushed to Firebase for secure storage.

### Cough Report

In this functionality, we collect the cough data pushed to Firebase and show it in three different graphs: daily, weekly and monthly. We allow the user to export this data for them to share with their doctors.



*Provide a comprehensive description of your application, including figures showing the application. You can learn more on how to structure a README in the [Stanford Spezi Documentation Guide](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/documentation-guide)*

> [!NOTE]  
> Do you want to learn more about the Stanford Spezi Template Application and how to use, extend, and modify this application? Check out the [Stanford Spezi Template Application documentation](https://stanfordspezi.github.io/SpeziTemplateApplication)


## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
