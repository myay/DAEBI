# DAEBI

A tool for the design-space exploration of BNN accelerators regarding different types of data flow and architectures. DAEBI automatically generates VHDL-code of BNN accelerator designs based on the user specifications.

- To generate an OS data flow design, use: `python3 generate_design.py --dataflow=OS --n=64 --m=1 --dw=16 --alpha=64 --beta=576 --delta=196`.
- For a WS data flow design, use: `python3 generate_design.py --dataflow=WS --n=64 --m=1 --dw=16 --nrregs=196 --alpha=64 --beta=576 --delta=196`.

To generate designs with other specifications, use the below a list of the command line parameters:
| Command line parameter | Options |
| :------------- |:-------------|
| --dataflow | String, dataflow type used in the design, options: OS, WS |
| --n | Integer, number of XNOR gates per column |
| --m | Integer, number of columns in accelerator |
| --dw | Integer, width of datapath (accumulator, registers, binarizer) |
| --nrregs | Integer, number of registers used in WS |
| --rrf | Integer, register reduction factor for WS, calculate by ceil(delta/nrregs) |
| --alpha | Integer, number of neurons to be processed |
| --beta | Integer, number of weights per neuron to be processed |
| --delta | Integer, second dimension of the input matrix |
| --debug | 0/1, 0: Production mode and 1: Debug mode (a few cycles of processing), default: 0 |
