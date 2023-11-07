# J5 Lint

Verilog/SystemVerilog Lint

## Purpose

Provide a CLI-based vendor-agnostic Verilog/SystemVerilog lint solution with
human-readable plain-text reports and lint violation filtering capability.

## Dependencies

* [Ruby](https://www.ruby-lang.org)
* [Mentor HDL Designer](https://www.mentor.com/products/fpga/hdl_design/hdl_designer_series)

## Usage

```sh
jflint --unit <unit> <module>
```

The `<unit>` argument is optional.  If it is not provided, the current working
directory will be used.

## Inputs

* Verilog Module (required) - `<module>`
* File List (required) - `<unit>/rtl/rtl.f`
* Waivers (optional) - `<unit>/lint/waivers.yml`

## Outputs

* Filtered Report - `$SBOX/lint/reports/<module>/violations.yml`
* Unfiltered Report - `$SBOX/lint/reports/<module>/violations_unfiltered.yml`

## Overview

1. Verilog/SystemVerilog files are obtained from the `<unit>/rtl/rtl.f` file
   list
2. The file list is transformed for Mentor HDL Designer
3. Mentor HDL Designer is run to lint the design
4. `jflint-format-report` is run to convert the Mentor HDL Designer reports from
   CSV to YAML
5. `jflint-filter` is run to apply waivers defined in `<unit>/lint/waivers.yml`
6. The final report is at `$SBOX/lint/reports/<module>/violations.yml`

## Creating Waivers

The preferred way of creating waivers is to copy and paste them from
`violations.yml` into `waivers.yml` then add a rationale.  Optionally remove
line number from the location field to make waiver less suceptible to being
invalidated due to RTL change.  Optionally remove severity, hint, and snippet
fields.  Hint and snippet fields are ignored.

Example violation to be waived:

```yaml
- rule: Arithmetic Overflow / Matching Widths
  location: hk/rtl/fe_credit_handling.v:234
  severity: ERROR
  message: Bit widths differ on left (8) and right (9) of assignment.
  hint: Ensure bit widths on both sides of an assignment match.
  snippet: |-
    232      end
    233      else if (cr_valid & ~rd_in_progress_or)
    234      hk_rdcmd_credits[7:0] <= hk_rdcmd_credits[7:0] + vp_rdcmd_credits;
    235      else if (cr_valid & rd_in_progress_or)
    236      hk_rdcmd_credits[7:0] <= hk_rdcmd_credits[7:0] + vp_rdcmd_credits - 1'b1;
```

Example waiver:

```yaml
- rule: Arithmetic Overflow / Matching Widths
  location: hk/rtl/fe_credit_handling.v
  message: Bit widths differ on left (8) and right (9) of assignment.
  rationale: Overflow condition is checked before performing addition.
```

## Waiver Specification

### Fields

* `rule` - (required) Matched against violation `rule` field using string
  comparison.
* `file` - (required) Supports two formats.

  * Path + Line - (Syntax: `<path>:<line_number>`) - Matched against both the
    `path` and `line_number` portions of the violation `file` field using
    string comparison.

    Example:

    ```yaml
      file: unit/rtl/unit.v:15
    ```

  * Globbed Path - (Syntax: `<globbed_path>`) - Matched against `path` portion
    of violation `file` field using [glob] comparison.  The `line_number`
    portion of the violation
    is ignored.

    Example:

    ```yaml
      file: unit/rtl/*fifo*.v
    ```

* `severity` - (optional) Matched against the violation `severity` field using
  string comparison.  When absent, matches any violation `severity`.

* `message` - (required) Supports two formats.

  * String - (Syntax: `<string>`) - Matched against the violation `message`
    field using string comparison.

    Example:

    ```yaml
      message: Bit widths potentially differ on left (6) and right (7) of assignment due
        to the use of conditional operator.
    ```

  * Regular Expresion - (Syntax: `!ruby/regexp '/<regex>/'`) - Matched against
    the violation `message` field using a regular expression.

    Example:

    ```yaml
    - rule: Arithmetic Overflow / Matching Widths
      location: hk/rtl/*.v
      severity: ERROR
      message: !ruby/regexp '/^Bit widths differ potentially differ on left \(\d+\) and right \(\d+\).*/'
    ```

* `hint` - (optional) Ignored.

* `rationale` - (required) Ignored.

[glob]: https://en.wikipedia.org/wiki/Glob_(programming)

## Exit Status

The exit status is non-zero (error) for any of the following:

* Presence of one or more lint violations with severity of ERROR, SYNTHESIS, or
  SYNTAX.
* Application errors

The exit status is zero (success) when lint violations have severities of
WARNING or NOTE only.

## See Also

[Lint Filter Specification](https://github.jpl.nasa.gov/rdonnell/lint-filter-specification)

== Generating the Man Page

```sh
docker run -u $UID -v "$PWD":/documents --rm -t asciidoctor/docker-asciidoctor \
    asciidoctor -b manpage -d manpage \
    -a manmanual="J5 Manual" \
    -a mansource="fpga-common master" \
    -a author="Rob Donnelly <robert.donnelly@jpl.nasa.gov>" \
    scripts/stow/jflint/docs/modules/cli/pages/jflint.adoc
mv scripts/stow/jflint/docs/modules/cli/pages/jflint.1 scripts/stow/jflint/share/man/man1
```
