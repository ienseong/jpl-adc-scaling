module JFLint
  module Filter
    class Statistics
      attr_accessor :violations
      attr_accessor :violations_syntax
      attr_accessor :violations_synthesis
      attr_accessor :violations_error
      attr_accessor :violations_warning
      attr_accessor :violations_note
      attr_accessor :remaining
      attr_accessor :remaining_synthesis
      attr_accessor :remaining_error
      attr_accessor :remaining_warning
      attr_accessor :remaining_note

      attr_accessor :waivers
      attr_accessor :valid_waivers
      attr_accessor :unmatched

      def waived
        violations - remaining
      end

      def waived_synthesis
        violations_synthesis - remaining_synthesis
      end

      def waived_error
        violations_error - remaining_error
      end

      def waived_warning
        violations_warning - remaining_warning
      end

      def waived_note
        violations_note - remaining_note
      end

      def invalid_waivers
        waivers - valid_waivers
      end

      def to_s
        counts = [
          'SYNTAX', 'SYNTHESIS', 'ERROR', 'WARNING', 'NOTE', 'Total',
          violations_syntax, violations_synthesis, violations_error, violations_warning, violations_note, violations,
          'n/a', waived_synthesis, waived_error, waived_warning, waived_note, waived,
          'n/a', remaining_synthesis, remaining_error, remaining_warning, remaining_note, remaining, remaining > 0 ? '(see violations.yml)' : '',
          waivers,
          invalid_waivers, invalid_waivers > 0 ? '(see ERRORs)' : '',
          unmatched, unmatched > 0 ? '(see ERRORs)' : '',
        ]

        <<~EOF % counts
          --------------------------------------------------------------------------------
          VIOLATIONS
          --------------------------------------------------------------------------------
                               %6s  %9s  %5s  %7s  %4s  %5s
             Total violations: %6s  %9s  %5d  %7d  %4s  %5d
            Waived violations: %6s  %9s  %5d  %7d  %4s  %5d
          Unwaived violations: %6s  %9s  %5d  %7d  %4s  %5d %s
          --------------------------------------------------------------------------------

          --------------------------------------------------------------------------------
          WAIVERS
          --------------------------------------------------------------------------------
              Total waivers: %4d
            Invalid waivers: %4d %s
          Unmatched waivers: %4d %s
          --------------------------------------------------------------------------------
        EOF
      end
    end
  end
end
