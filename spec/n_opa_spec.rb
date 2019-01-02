RSpec.describe NOpa do
  it "has a version number" do
    expect(NOpa::VERSION).not_to be nil
  end

  let(:root) { File.expand_path('../..', __FILE__) + '/spec/' }
  let(:algorithm) { NOpa::DynamicAlgorithm.new(input, **params) }
  let(:params) { {} }

  describe 'input validation' do
    context 'having no items' do
      let(:input) { [] }

      it { expect { algorithm }.to raise_error(NOpa::InputError, 'missing items to assign') }
    end

    context 'having items' do
      context 'item but no slot arrays' do
        let(:input) { [1] }

        it { expect { algorithm }.to raise_error(NOpa::InputError, 'slot values per item should be arrays') }
      end

      context 'having unequal slot sizes' do
        let(:input) { [[2], [1,2]] }

        it 'slot sizes should be equal' do
          expect { algorithm }.to raise_error(NOpa::InputError, 'must have the same number of slots per item')
        end
      end
    end
  end

  describe 'profits' do
    let(:input) { profits }

    context 'validation' do
      let(:profits) { [[1,2],[2,-1]] }

      it 'does not accept negative profits' do
        expect { algorithm }.to raise_error(NOpa::InputError, 'Cannot have negative profits')
      end
    end

    context 'having valid input and injective #compute' do
      # here i values cannot map to the same assigment t
      before { algorithm.compute }

      context 'having complex profit values 1' do
        let(:profits) { [[7,6,2,5,6],[1,4,3,1,8]] }

        it 'computes non-contiguous assignments 1' do
          expect(algorithm.assignments).to eq([0,4])
        end
      end

      context 'having complex profit values 2' do
        let(:profits) { [[7,6,8,5,6],[1,4,3,1,8]] }

        it 'computes non-contiguous assignments 2' do
          expect(algorithm.assignments).to eq([2,4])
        end
      end

      context 'having out of order assignments' do
        let(:profits) { [[2,1,4],[3,1,2]] }

        it { expect(algorithm.assignments).to eq([0,2]) }
      end

      context 'having no overlapping values' do
        let(:profits) { [[1,2,3],[1,2,3]] }

        it { expect(algorithm.assignments).to eq([1,2]) }
      end

      context 'having a single value' do
        let(:profits) { [[1]] }

        it { expect(algorithm.assignments).to eq([0]) }
      end

      context 'having square dimension' do
        let(:profits) { [[1,3],[3,2]] }

        it { expect(algorithm.assignments).to eq([0,1]) }
      end

      context 'having first and last out of order' do
        let(:profits) { [[3,1,1,1,4],[1,1,5,1,1],[4,1,1,1,3]] }

        it 'computes 3 assignees' do
          expect(algorithm.assignments).to eq([0,2,4])
        end
      end

      context 'having all equal profit values' do
        let(:profits) { [[1,1,1,1,1],[1,1,1,1,1],[1,1,1,1,1]] }

        it { expect(algorithm.assignments).to eq([0,1,2]) }
      end

      context 'having zero values treated the same' do
        let(:profits) { [[3,0,1,1,4],[1,1,5,1,0], [4,1,1,0,3]] }

        it { expect(algorithm.assignments).to eq([0,2,4]) }
      end

      # context 'complex' do
      #   let(:profits) { [] }
      # end
    end
  end

  describe 'costs' do
    let(:params) { { costs: true } }
    let(:input) { costs }

    context 'validation' do
      let(:costs) { [[1,2],[2,-1]] }

      it 'does not accept negative costs' do
        expect { algorithm }.to raise_error(NOpa::InputError, 'Cannot have negative costs')
      end
    end

    context 'having square dimension' do
      let(:costs) { [[3,1],[1,2]] }
      before { algorithm.compute }

      it { expect(algorithm.assignments).to eq([0,1]) }
    end

    context 'having a single value' do
      let(:costs) { [[1]] }
      before { algorithm.compute }

      it { expect(algorithm.assignments).to eq([0]) }
    end

    context 'having all equal cost values' do
      let(:costs) { [[1,1,1,1,1],[1,1,1,1,1],[1,1,1,1,1]] }
      before { algorithm.compute }

      it { expect(algorithm.assignments).to eq([0,1,2]) }
    end

    context 'having no overlapping values' do
      let(:costs) { [[1,2,3],[1,2,3]] }
      before { algorithm.compute }

      it { expect(algorithm.assignments).to eq([0,1]) }
    end

    context 'having out of order assignments' do
      let(:costs) { [[2,4,0],[1,4,2]] }
      before { algorithm.compute }

      it { expect(algorithm.assignments).to eq([0,2]) }
    end

    context 'having complex cost values' do
      let(:costs) { [[2,3,1,4,2],[10,5,6,10,1]] }
      before { algorithm.compute }

      it 'computes non-contiguous assignments' do
        expect(algorithm.assignments).to eq([2,4])
      end
    end

    context 'having zero values treated the same' do
      let(:costs) { [[3,0,1,1,4],[1,1,5,1,0],[4,1,1,0,3]] }
      before { algorithm.compute }

      it { expect(algorithm.assignments).to eq([0,1,3]) }
    end

    context 'max match not optimal choice for each of every item' do
      let(:costs) { [[2,1,0,2,2], [2,3,1,0,2], [2,3,0,1,4]] }
      before { algorithm.compute }

      it { expect(algorithm.assignments).to eq([1,2,3]) }
    end

    context 'complex' do
      # A "real-world" example
      let(:costs) { File.open(root + 'complex-array.yml', 'r') { |f| YAML::load(f)  } }
      subject { algorithm.compute }

      # it { expect{ subject }.to perform_power }
      it { subject; expect(algorithm.assignments).to eq([0, 10, 11, 13, 14, 15, 17, 21, 22, 23, 24, 25, 28, 29, 31, 32, 33, 34, 35, 36, 39, 40, 42, 43, 45, 47, 48, 49, 50, 52, 54, 55, 58, 63, 71]) }
    end

    context 'complex 2' do
      # Another "real-world" example with large inputs
      let(:costs) { File.open(root + 'complex-array-2.yml', 'r') { |f| YAML::load(f)  } }
      subject { algorithm.compute }

      it { subject; expect(algorithm.assignments).to eq([21,35,51,63,79,91,103,113,127,139,165,178,190,204,216,233,255,264,281,305,313,331,342,351,358,371,389,405,416,439,466,499,506,515,546,592,607,624,632,646,657,666,680,693,706,716,725,733,739,747,762,773,787,802,812,821,835,846,853,866,875,892,905,914,921,944,961,969,982,990,1009,1011,1029,1041,1056,1067,1072,1091,1097,1105,1109,1125,1127,1150,1160,1172]) }
      # it { expect{ subject }.to perform_power }
    end
  end
end
