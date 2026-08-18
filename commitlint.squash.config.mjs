import base from "./commitlint.config.mjs";

// Config for the squash-merge message (PR title + description), the commit
// release-please actually parses. Two departures from the per-commit config:
// the description is markdown, so the commit line-length limits cannot apply;
// and a `!` subject is only a marker, so the footer carrying the prose is
// required here (conventions C4).
const BREAKING_HEADER = /^[a-zA-Z]+(\([^)]*\))?!:/;

const breakingChangeFooter = {
  rules: {
    "breaking-change-footer": ({ header, subject, notes }) => {
      if (!BREAKING_HEADER.test(header ?? "")) {
        return [true];
      }

      const note = (notes ?? []).find((entry) =>
        /^BREAKING[ -]CHANGE$/.test(entry.title ?? ""),
      );
      const text = (note?.text ?? "").trim();

      // A missing footer is indistinguishable from one repeating the subject:
      // the parser synthesises the note from `!` using the subject, which is
      // why release-please renders the subject when no footer was written.
      const stated = text !== "" && text !== (subject ?? "").trim();

      return [
        stated,
        "a `!` subject needs a `BREAKING CHANGE: <effect>` footer at the end of the PR description, stating what a consumer must change: release-please copies that footer into the release notes and CHANGELOG.md, and falls back to the subject when it is absent",
      ];
    },
  },
};

export default {
  ...base,
  plugins: [breakingChangeFooter],
  rules: {
    ...(base.rules ?? {}),
    "body-max-line-length": [0],
    "footer-max-line-length": [0],
    "breaking-change-footer": [2, "always"],
  },
};
