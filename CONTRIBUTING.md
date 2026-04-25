# Contributing to FlitPDF

Thank you for helping improve FlitPDF. This project is open to bug reports, documentation improvements, design polish, tests, refactors, and new features that fit the product direction.

## Ways to Contribute

- Report bugs with clear reproduction steps
- Propose focused feature requests
- Improve docs, onboarding, and developer setup
- Submit code changes with tests or manual verification notes
- Help review UX, accessibility, and performance issues

## Before You Start

- Check existing issues and pull requests before opening a new one
- Use the GitHub issue templates so reports stay actionable
- For larger changes, open an issue first to align on scope

## Development Setup

```bash
flutter pub get
flutter run
```

Optional local-only setup:

- Firebase features: add `android/app/google-services.json`
- Google Sign-In: run with `--dart-define=FLITPDF_GOOGLE_SERVER_CLIENT_ID=...`
- Release signing: copy `android/key.properties.example` to `android/key.properties` and add `android/app/upload-keystore.jks`

None of those private files should be committed.

## Pull Request Guidelines

- Keep pull requests focused and easy to review
- Update documentation when behavior or setup changes
- Add tests when practical, or explain the manual verification you performed
- Avoid unrelated formatting-only churn
- Never commit secrets, keystores, or production-only credentials

## Coding Expectations

- Follow the existing Flutter and Dart style already used in the repo
- Prefer small, readable changes over broad rewrites
- Preserve existing license and attribution notices

## Contribution Licensing

By submitting a contribution, you agree that your work will be licensed under the repository's MIT License.

## Attribution and Branding

You are welcome to fork and extend the codebase, but please do not present a modified version as the official FlitPDF project. Use distinct branding for redistributed forks and preserve upstream attribution.

See [TRADEMARKS.md](TRADEMARKS.md) for branding rules.

## Community Standards

By participating in this project, you agree to follow [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
