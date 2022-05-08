require 'spec_helper'

describe 'class_params_newline' do
  let(:msg) { 'Parameter %s should have its own line (expected in line %d, but found it in line %d)' }

  context 'with fix disabled' do
    context 'tidy code' do
      let(:code) do
        <<-END
          class bar(
                                                        $someparam = 'somevalue',
                                                        $another,
            String                                      $nope,
                                                        $foo,
            Variant[Undef, Enum['UNSET'], Stdlib::Port] $db_port,
            # $aaa,
            String                                      $third     = 'meh',
            Array[Int, Int]                             $asdf      = 'asdf',
          ) { }
        END
      end

      it 'should detect 0 problems' do
        expect(problems).to have(0).problems
      end
    end

    context 'messy code' do
      let(:code) do
        <<-END
          class bar(                                                        $someparam = 'somevalue',
            $another, String $nope, $foo,
            Variant[Undef, Enum['UNSET'], Stdlib::Port] $db_port,
            # $aaa,
            String                                              $third     = 'meh', Array[Int, Int] $asdf = 'asdf',
          ) { }
        END
      end

      it 'should detect 4 problems' do
        expect(problems).to have(4).problems
      end

      it 'should create four warnings' do
        expect(problems).to contain_warning(format(msg, '$someparam', 2, 1)).on_line(1).in_column(77)
        expect(problems).to contain_warning(format(msg, '$nope', 3, 2)).on_line(2).in_column(30)
        expect(problems).to contain_warning(format(msg, '$foo', 3, 2)).on_line(2).in_column(37)
        expect(problems).to contain_warning(format(msg, '$asdf', 6, 5)).on_line(5).in_column(101)
      end
    end
  end

  context 'with fix enabled' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    context 'messy code' do
      let(:code) do
        <<-END
          class bar(                                                        $someparam = 'somevalue',
            $another, String $nope, $foo,
            Variant[Undef, Enum['UNSET'], Stdlib::Port] $db_port,
            # $aaa,
            String                                              $third     = 'meh', Array[Int, Int] $asdf = 'asdf',
          ) { }
        END
      end

      let(:fixed) do
        <<-END
          class bar(
            $someparam = 'somevalue',
            $another,
            String $nope,
            $foo,
            Variant[Undef, Enum['UNSET'], Stdlib::Port] $db_port,
            # $aaa,
            String                                              $third     = 'meh',
            Array[Int, Int] $asdf = 'asdf',
          ) { }
        END
      end

      it 'should fix the problems' do
        expect(manifest).to eq(fixed)
      end
    end
  end
end