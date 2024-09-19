-- -----------------------------------------------------------------------------
--
--  Title      :  FSMD implementation of GCD
--             :
--  Developers :  Jens Sparsø, Rasmus Bo Sørensen and Mathias Møller Bruhn
--           :
--  Purpose    :  This is an FSMD (finite state machine with datapath) 
--             :  implementation for the GCD circuit
--             :
--  Revision   :  02203 fall 2019 v.5.0
--
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd is
  port (
    clk : in std_logic;               -- The clock signal.
    reset : in std_logic;             -- Reset the module.
    req : in std_logic;               -- Input operand / start computation.
    AB : in unsigned(15 downto 0);    -- The two operands (A and B combined).
    ack : out std_logic;              -- Computation is complete.
    C : out unsigned(15 downto 0)     -- The result (GCD).
  );
end gcd;

architecture fsmd of gcd is

  -- Define state type and signals
  type state_type is (S0, S1, S2, S3, S4); -- States representing FSM states

  signal reg_a, next_reg_a : unsigned(15 downto 0);
  signal reg_b, next_reg_b : unsigned(15 downto 0);
  signal state, next_state : state_type;

begin

  -- Combinational logic for state transitions and output logic
  cl : process (req, AB, state, reg_a, reg_b, reset)
  begin
    -- Default assignments
    next_reg_a <= reg_a;
    next_reg_b <= reg_b;
    next_state <= state;
    ack <= '0';
    
    case state is
      -- State S0: Initialization
      when S0 =>
      next_reg_a <= AB(15 downto 0);
      next_reg_b <= (others => 'Z');
        if req = '1' then
          next_state <= S1;
        end if;

      -- State S1: Loading input A
      when S1 =>
        ack <= '1';
        if req = '0' then
          next_state <= S2;  
        end if;

      -- State S2: A := Loading input B
      when S2 =>
      next_reg_b <= AB(15 downto 0);
      ack <= '0';
        if req = '1' then
            next_state <= S3;
        end if;
    
      -- State S3: GCD
      when S3 =>
        if reg_a < reg_b then
            next_reg_b <= reg_b - reg_a;
            next_state <= S3;
        elsif reg_a = reg_b then
            next_state <= S4;
        else 
            next_reg_a <= reg_a - reg_b;
            next_state <= S3; 
        end if;
        
        
      -- State S4: Finished
      when S4 =>
      ack <= '1';
      c <= reg_a;
        if req = '0' then
          next_state <= S0;  -- Return to idle state
        end if;

      -- Default case
      when others =>
        next_state <= S0;
    end case;
  end process cl;

  -- Sequential logic (state register and data register updates)
  seq : process (clk, reset)
  begin
    if reset = '1' then
      -- Reset registers and state
      state <= S0;
      reg_a <= (others => '0');
      reg_b <= (others => '0');
    elsif rising_edge(clk) then
      state <= next_state;
      reg_a <= next_reg_a;
      reg_b <= next_reg_b;
    end if;
  end process seq;

end fsmd;