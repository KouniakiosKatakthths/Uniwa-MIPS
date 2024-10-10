library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity mux2to1 is
    generic (
        dataSize: natural
    );
    port (
        a1: in std_logic_vector(dataSize - 1 downto 0);
        a2: in std_logic_vector(dataSize - 1 downto 0);
        s: in std_logic;
        o: out std_logic_vector(dataSize - 1 downto 0)
    );
end entity;

architecture dataflow of mux2to1 is
begin
  process(a1, a2, s)
  begin
    if s = '0' then
      o <= a1;
    else 
      o <= a2;
    end if;
  end process;
end architecture;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity registers is
  generic (
    size: natural;
    cellSize: natural;
    addrSize: natural
  );
  
  port (
    readAddr1: in std_logic_vector(addrSize - 1 downto 0);
    readAddr2: in std_logic_vector(addrSize - 1 downto 0);
    writeAddr: in std_logic_vector(addrSize - 1 downto 0);
    dataIn: in std_logic_vector(cellSize - 1 downto 0);
    regWrite: in std_logic;
    clk: in std_logic;
    reset: in std_logic;
    dataOut1: out std_logic_vector(cellSize - 1 downto 0);
    dataOut2: out std_logic_vector(cellSize - 1 downto 0)
  );
end entity;

architecture dataflow of registers is
    type regFile is array(0 to size - 1) of std_logic_vector(cellSize - 1 downto 0);
    signal reg: regFile;
begin

    process(clk, readAddr1, readAddr2)
    begin
        if falling_edge(clk) then
            if regWrite = '1' then
                reg(to_integer(unsigned(writeAddr))) <= dataIn;
            end if;

            if reset = '1' then
                for i in 0 to size - 1 loop
                    reg(i) <= (others => '0');
                end loop;
            end if;
        end if;
        
        dataOut1 <= reg(to_integer(unsigned(readAddr1)));
        dataOut2 <= reg(to_integer(unsigned(readAddr2)));
    end process;
end architecture;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity instructionRegisters is
  port (
    addr: in std_logic_vector(3 downto 0);
    clk: in std_logic;
    reset: in std_logic;
    instruction: out std_logic_vector(31 downto 0)
  );
end entity;

architecture dataflow of instructionRegisters is
    type regFile is array(0 to 15) of std_logic_vector(31 downto 0);
    signal reg: regFile := (
        x"20000000",    --addi $0, $0, 0      (0)
        x"20420000",    --addi $2, $2, 0      (1)
        x"20820000",    --addi $2, $4, 0      (2)
        x"20030001",    --addi $3, $0, 1      (3)
        x"20050003",    --addi $5, $0, 3      (4)
        x"00603020",    --L1: add $6, $3, $0  (5)
        x"AC860000",    --  sw $6, 0($4)      (6)
        x"20630001",    --  addi $3, $3, 1    (7)
        x"20840001",    --  addi $4, $4, 1    (8)
        x"20A5FFFF",    --  addi $5, $5, -1   (9)
        x"14A0FFFA",    --bne $5,$0,L1        (A)
        x"00000000",    --(B)
        x"00000000",    --(C)
        x"00000000",    --(D)
        x"00000000",    --(E)
        x"00000000"     --(F)
    );
begin
    process(clk)
    begin
        instruction <= reg(to_integer(unsigned(addr)));
    end process;
end architecture;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity dataRegister is
  generic (
    size: natural;
    cellSize: natural;
    addrSize: natural
  );
  port (
    addr: in std_logic_vector(addrSize - 1 downto 0);
    dataIn: in std_logic_vector(cellSize - 1 downto 0);
    memWrite: in std_logic;
    memRead: in std_logic;
    clk: in std_logic;
    reset: in std_logic;
    dataOut: out std_logic_vector(cellSize - 1 downto 0)
  );
end entity;

architecture dataflow of dataRegister is
    type regFile is array(0 to size - 1) of std_logic_vector(cellSize - 1 downto 0);
    signal reg: regFile;
begin
    process(clk, addr)
    begin
        if falling_edge(clk) then
            if memWrite = '1' then
                reg(to_integer(unsigned(addr))) <= dataIn;
            end if;

            if reset = '1' then
                for i in 0 to size - 1 loop
                    reg(i) <= (others => '0');
                end loop;
            end if;
        end if;
        
        if memRead = '1' then
          dataOut <= reg(to_integer(unsigned(addr)));
        end if;
    end process;
end architecture;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ALU is
  generic (
    size: natural
  );
  port (
    dataIn1: in std_logic_vector(size - 1 downto 0);
    dataIn2: in std_logic_vector(size - 1 downto 0);
    ALUctrl: in std_logic_vector(3 downto 0);
    dataOut: out std_logic_vector(size - 1 downto 0);
    zero: out std_logic
  );
end entity;

architecture dataflow of ALU is
    signal result: std_logic_vector(size - 1 downto 0);
begin
    process(ALUctrl, dataIn1, dataIn2)
    begin
        if ALUctrl = "1101" then      --Add
            result <= std_logic_vector(signed(dataIn1) + signed(dataIn2));
        elsif ALUctrl = "0110" then   --Sub
            result <= std_logic_vector(signed(dataIn1) - signed(dataIn2));
        elsif ALUctrl = "0000" then   --And
            result <= dataIn1 and dataIn2;
        elsif ALUctrl = "0001" then   --Or
            result <= dataIn1 or dataIn2; 
        else
            result <= std_logic_vector(signed(dataIn1) + signed(dataIn2));
        end if;
    end process;

    zero <= '1' when result = x"00000000" else '0';
    dataOut <= result;
end architecture;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity CTRUnit is
  port (
    instruction: in std_logic_vector(5 downto 0);
    ctrSignals: out std_logic_vector(8 downto 0)
    
    --regDest -> ctrSignals(8)
    --ALUSrc -> ctrSignals(7)
    --memToReg -> ctrSignals(6)
    --regWrite -> ctrSignals(5)
    --memRead -> ctrSignals(4)
    --memWrite -> ctrSignals(3)
    --branch -> ctrSignals(2)
    --ALUOp1 -> ctrSignals(1)
    --ALUOp2 -> ctrSignals(0)
  );
end entity;

architecture dtaaflow of CTRUnit is
begin
  process(instruction)
  begin
    case (instruction) is
      when "000000" =>         --Type R
        ctrSignals(8) <= '1';
        ctrSignals(7) <= '0';
        ctrSignals(6) <= '0';
        ctrSignals(5) <= '1';
        ctrSignals(4) <= '0';
        ctrSignals(3) <= '0';
        ctrSignals(2) <= '0';
        ctrSignals(1) <= '1';
        ctrSignals(0) <= '0';
      when "001000" =>        --Addi
        ctrSignals(8) <= '0';
        ctrSignals(7) <= '1';
        ctrSignals(6) <= '0';
        ctrSignals(5) <= '1';
        ctrSignals(4) <= 'X';
        ctrSignals(3) <= 'X';
        ctrSignals(2) <= '0';
        ctrSignals(1) <= '0';
        ctrSignals(0) <= '0';
      when "101011" =>        --Sw
        ctrSignals(8) <= 'X';
        ctrSignals(7) <= '1';
        ctrSignals(6) <= 'X';
        ctrSignals(5) <= '0';
        ctrSignals(4) <= '0';
        ctrSignals(3) <= '1';
        ctrSignals(2) <= '0';
        ctrSignals(1) <= '0';
        ctrSignals(0) <= '0';
      when "000101" =>        --Bne
        ctrSignals(8) <= 'X';
        ctrSignals(7) <= '0';
        ctrSignals(6) <= 'X';
        ctrSignals(5) <= '0';
        ctrSignals(4) <= '0';
        ctrSignals(3) <= '0';
        ctrSignals(2) <= '1';
        ctrSignals(1) <= '0';
        ctrSignals(0) <= '1';
      when others =>

    end case;
  end process;
end architecture;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity AULCtr is
  port (
    opCode: in std_logic_vector(5 downto 0);
    aluOp1: in std_logic;
    aluOp2: in std_logic;
    operation: out std_logic_vector(3 downto 0)
  );
end entity;

architecture dataflow of AULCtr is
begin
  process(opCode, aluOp1, aluOp2)
  begin
    operation(3) <= '0';
    operation(2) <= (opCode(1) and aluOp2) or aluOp1;
    operation(1) <= not opCode(2) or not aluOp2;
    operation(0) <= (opCode(3) or opCode(0)) and aluOp2;
  end process;
end architecture;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ProgramCounter is
  port (
    currentInstruction: in std_logic_vector(3 downto 0);
    jumpCouner: in std_logic_vector(3 downto 0);
    brance: in std_logic;
    aluZero: in std_logic;
    clk: in std_logic;
    reset: in std_logic;
    counter: out std_logic_vector(3 downto 0)
  );
end entity;

architecture dataflow of ProgramCounter is
begin
  process(clk)
  begin
    if falling_edge(clk) then
      if reset = '1' then
        counter <= x"0";
      else
        if brance = '1' and aluZero = '0' then 
          counter <= std_logic_vector(signed(currentInstruction) + signed(jumpCouner) + 1);
        else 
          counter <= std_logic_vector(unsigned(currentInstruction) + 1);
        end if;
      end if;
    end if;

  end process;
end architecture;


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.ceil;
  use ieee.math_real.log2;

entity mips is
  port (
    clk: in std_logic;
    reset: in std_logic
  );
end entity;

architecture dataflow of mips is
    constant l_size: natural := 16;
    constant l_cellSize: natural := 32;
    constant l_addrSize: natural := natural(ceil(log2(real(l_size))));

    component registers is
      generic (
        size: natural := l_size;
        cellSize: natural := l_cellSize;
        addrSize: natural := l_addrSize
      );
      port (
        readAddr1: in std_logic_vector(addrSize - 1 downto 0);
        readAddr2: in std_logic_vector(addrSize - 1 downto 0);
        writeAddr: in std_logic_vector(addrSize - 1 downto 0);
        dataIn: in std_logic_vector(cellSize - 1 downto 0);
        regWrite: in std_logic;
        clk: in std_logic;
        reset: in std_logic;
        dataOut1: out std_logic_vector(cellSize - 1 downto 0);
        dataOut2: out std_logic_vector(cellSize - 1 downto 0)
      );
    end component;

    component instructionRegisters is
      port (
        addr: in std_logic_vector(3 downto 0);
        clk: in std_logic;
        reset: in std_logic;
        instruction: out std_logic_vector(31 downto 0)
      );
    end component;

    component dataRegister is
      generic (
        size: natural := l_size;
        cellSize: natural := l_cellSize;
        addrSize: natural := l_addrSize
      );
      port (
        addr: in std_logic_vector(addrSize - 1 downto 0);
        dataIn: in std_logic_vector(cellSize - 1 downto 0);
        memWrite: in std_logic;
        memRead: in std_logic;
        clk: in std_logic;
        reset: in std_logic;
        dataOut: out std_logic_vector(cellSize - 1 downto 0)
      );
    end component;
    
    component CTRUnit is
      port (
        instruction: in std_logic_vector(5 downto 0);
        ctrSignals: out std_logic_vector(8 downto 0)

        --###### Control Signals Map ######
        --regDest -> ctrSignals(8)
        --ALUSrc -> ctrSignals(7)
        --memToReg -> ctrSignals(6)
        --regWrite -> ctrSignals(5)
        --memRead -> ctrSignals(4)
        --memWrite -> ctrSignals(3)
        --branch -> ctrSignals(2)
        --ALUOp1 -> ctrSignals(1)
        --ALUOp2 -> ctrSignals(0)
      );
    end component; 

    component ALU is
      generic (
        size: natural := l_cellSize
      );
      port (
        dataIn1: in std_logic_vector(size - 1 downto 0);
        dataIn2: in std_logic_vector(size - 1 downto 0);
        ALUctrl: in std_logic_vector(3 downto 0);
        dataOut: out std_logic_vector(size - 1 downto 0);
        zero: out std_logic
      );
    end component;

    component AULCtr is
      port (
        opCode: in std_logic_vector(5 downto 0);
        aluOp1: in std_logic;
        aluOp2: in std_logic;
        operation: out std_logic_vector(3 downto 0)
      );
    end component;

    component mux2to1 is
      generic (
        dataSize: natural
      );
      port (
        a1: in std_logic_vector(dataSize - 1 downto 0);
        a2: in std_logic_vector(dataSize - 1 downto 0);
        s: in std_logic;
        o: out std_logic_vector(dataSize - 1 downto 0)
      );
    end component;

    component ProgramCounter is
      port (
        currentInstruction: in std_logic_vector(3 downto 0);
        jumpCouner: in std_logic_vector(3 downto 0);
        brance: in std_logic;
        aluZero: in std_logic;
        clk: in std_logic;
        reset: in std_logic;
        counter: out std_logic_vector(3 downto 0)
      );
    end component;

    signal l_currentAddress: std_logic_vector(l_addrSize - 1 downto 0) := (others => '0');  --The program "counter"
    signal l_instruction: std_logic_vector(31 downto 0) := x"00000000";                     --The current Instruction

    signal l_regWrite: std_logic_vector(l_addrSize - 1 downto 0);                           --The reg to write
    signal l_regDataIn: std_logic_vector(l_cellSize - 1 downto 0);                          --The data to be writtent to the registers

    signal l_out1, l_out2: std_logic_vector(l_cellSize - 1 downto 0);                       --The outputs of the program registers
    signal l_ctrSingals: std_logic_vector(8 downto 0);                                      --The control signals for this cycle

    signal l_aluInput2: std_logic_vector(l_cellSize - 1 downto 0);                          --The input signal of the second input the alu
    signal l_aluOperation: std_logic_vector(3 downto 0);                                    --The operation of the ALU createted from the ALUCtr
    signal l_ALUResult: std_logic_vector(l_cellSize -1 downto 0);                           --The result of the alu
    signal l_zero: std_logic;                                                               --Zero flag
    
    signal l_memoryOut: std_logic_vector(l_cellSize - 1 downto 0);
    
    --Extends the signal from 16 to 32 bits (Signed)
    function SignedExtent(l_input: std_logic_vector(15 downto 0)) return std_logic_vector is
      variable vec: std_logic_vector(31 downto 0);
    begin
      if l_input(15) = '0' then
        vec(31 downto 16) := x"0000";
      else
        vec(31 downto 16) := x"FFFF";
      end if;
      vec(15 downto 0) := l_input;
      return vec;
    end function;
begin

    instructReg: instructionRegisters port map(     --Reads instructions from instruction memory
      addr => l_currentAddress, 
      clk => clk, 
      reset => reset, 
      instruction => l_instruction
    );

    ctr: CTRUnit port map(                          --Generate the control signal
      instruction => l_instruction(31 downto 26), 
      ctrSignals => l_ctrSingals
    );
    
    writeRegMux: mux2to1 generic map(dataSize => l_addrSize) port map(     --Select the write register
      a1 => l_instruction(19 downto 16),    
      A2 => l_instruction(14 downto 11), 
      s => l_ctrSingals(8), 
      o => l_regWrite
    );
    
    programReg: registers port map(
      readAddr1 => l_instruction(24 downto 21), 
      readAddr2 => l_instruction(19 downto 16), 
      writeAddr => l_regWrite, 
      dataIn => l_regDataIn, 
      regWrite => l_ctrSingals(5), 
      clk => clk, 
      reset => reset, 
      dataOut1 => l_out1, 
      dataOut2 => l_out2
    );

    aluSrc: mux2to1 generic map(dataSize => l_cellSize) port map(   --Select the out of reg2 or the immidiete
      a1 => l_out2, 
      a2 => SignedExtent(l_instruction(15 downto 0)), 
      s => l_ctrSingals(7), 
      o => l_aluInput2
    );
    
    generateAluCtr: AULCtr port map(
      opCode => l_instruction(5 downto 0),
      aluOp1 => l_ctrSingals(0),
      aluOp2 => l_ctrSingals(1),
      operation => l_aluOperation
    );

    mainAlu: ALU port map(
      dataIn1 => l_out1,
      dataIn2 => l_aluInput2,
      ALUctrl => l_aluOperation,
      dataOut => l_ALUResult,
      zero => l_zero
    );

    dataReg: dataRegister port map(
      addr => l_ALUResult(3 downto 0),
      dataIn => l_out2,
      memRead => l_ctrSingals(4),
      memWrite => l_ctrSingals(3),
      clk => clk,
      reset => reset,
      dataOut => l_memoryOut
    );

    writeRegCtr: mux2to1 generic map (dataSize => l_cellSize) port map(
      a1 => l_ALUResult,
      a2 => l_memoryOut,
      s => l_ctrSingals(6),
      o => l_regDataIn
    );

    programCtr: ProgramCounter port map(
      currentInstruction => l_currentAddress,
      jumpCouner => l_instruction(3 downto 0),
      brance => l_ctrSingals(2),
      aluZero => l_zero,
      clk => clk,
      reset => reset,
      counter => l_currentAddress
    );
end architecture;
