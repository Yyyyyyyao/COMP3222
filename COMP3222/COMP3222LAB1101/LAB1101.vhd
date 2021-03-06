LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY LAB1101 IS

	PORT(SW: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		  KEY: IN STD_LOGIC_VECTOR(0 TO 0);
		  clock_50: IN STD_LOGIC;
		  LEDR: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		  LEDG: OUT STD_LOGIC_VECTOR(0 TO 0));



	--PORT(Clock, Resetn: IN STD_LOGIC;
		--  LA, s : IN STD_LOGIC;
		  --Data: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		  --B :BUFFER INTEGER RANGE 0 TO 8;
		  --Done: OUT STD_LOGIC);
END LAB1101;

ARCHITECTURE Behavior OF LAB1101 IS

	COMPONENT shiftrne
		GENERIC(N: INTEGER := 8);
		PORT(R :IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
			  L, E, w, Clock: IN STD_LOGIC;
			  Q: BUFFER STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;

TYPE State_type IS (S1, S2, S3);
SIGNAL y: State_type;
SIGNAL A: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL z, EA, LB, EB, low: STD_LOGIC;
SIGNAL Clock, Resetn, LA, s, Done: STD_LOGIC;
SIGNAL Data: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL B: STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN 
	Resetn <= KEY(0);
	Data <= SW(7 DOWNTO 0);
	s <= SW(8);
	LEDG(0) <= Done;
	LEDR(3 DOWNTO 0) <= B;
	Clock <= clock_50;
	
	

	FSM_transitions: PROCESS(Resetn, Clock)
	BEGIN 
		IF Resetn = '0' THEN
			y <= S1;
		ELSIF(Clock'EVENT AND Clock = '1') THEN
			CASE y IS 
				WHEN S1 =>
					IF s = '0' THEN 
						y <= S1;
					ELSE 
						y <= S2;
					END IF;
				WHEN S2 =>
					IF z = '0' THEN
						y <= S2;
					ELSE 
						y <= S3;
					END IF;
				WHEN S3 =>
					IF s = '1' THEN 
						y <= S3;
					ELSE 
						y <= S1;
					END IF;
			END CASE;
		END IF;
	END PROCESS;

	FSM_outputs: PROCESS(y, A(0))
	BEGIN 
		EA <= '0';
		LB <= '0';
		EB <= '0';
		Done <= '0';
		LA <= '0';
		
		CASE y IS 
			WHEN S1 =>
				LB <= '1';
				LA <= '1';
			WHEN S2 =>
				EA <= '1';
				IF(A(0) = '1') THEN 
					EB <= '1';
				END IF;
			WHEN S3 =>
				Done <= '1';
		END CASE;
		
	END PROCESS;
	
	upcount: PROCESS(Resetn, Clock)
	BEGIN 
		IF Resetn = '0' THEN
			B <= "0000";
		ELSIF(Clock'EVENT AND Clock = '1')THEN
			IF EB = '1' THEN	
				B <= B+'1';
			END IF;
		END IF;
	END PROCESS;
	
	low <= '0';
	ShiftA: shiftrne GENERIC MAP(N => 8)
		PORT MAP(Data, LA, EA, low, Clock, A);
	z  <= '1' WHEN A = "00000000" ELSE '0';
	
	

	
END Behavior;


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY shiftrne IS
	GENERIC(N: INTEGER := 8);
	PORT(R :IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		  L, E, w, Clock: IN STD_LOGIC;
		  Q: BUFFER STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END shiftrne;

ARCHITECTURE Behavior OF shiftrne IS
BEGIN 
	PROCESS
	BEGIN 
		WAIT UNTIL Clock'EVENT AND Clock = '1';
		IF L = '1' THEN
			Q <= R;
		ELSIF E = '1' THEN
			Q(N-1) <= w;
			Genbits: FOR i IN 0 TO N-2 LOOP
				Q(i) <= Q(i+1);
			END LOOP;
		END IF;
	END PROCESS;
	
END Behavior;


		  