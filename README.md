# Traffic Light System (TLS)

TLS circuit will receive Gin, Yin, Rin signals representing the duration time of green light, yellow light and red light respectively, and output traffic light signal by Gout, Yout, and Rout according to the state of the system. 

The specification and the main functions of TLS circuit will be described in detail in Document.pdf.

## Application

主要分為: controller 模組和 data path 模組，其中 data path 模組又分為  counter 模組、compare 模組。
** Controller : 以兩個 combinational circuit 和一個 Sequential circuit 組成 ** 
- 燈號順序為: 綠、黃、紅、綠......
- Sequential circuit: state register
- If Set = 1 or reset = 1: current state = green light
- If Jump = 1: current state = red light
- If Stop = 1: current state = current state
- Else current state = next state
- 1st combinational circuit: next state logic
- 根據 current state: 
  - If recount = 1 => next state 為下一個燈號順序，否則保持原燈號
  - 2nd combinational circuit: output logic
- 根據current state 決定 control signal
** Counter: 一個Sequential circuit 組成 **
- If (rst | Jump | Set | Recount_counter) => count out = 1
- If Stop => count out = count out
- Else count out = count out + 1
** Compare: 以一個 combinational circuit 和一個 Sequential circuit 組成 **
- Sequential circuit: 儲存各燈號秒數
- If Set = 1 => 將Rin, Yin, Gin 存入 register
- Sequential circuit: 比較counter 是否等於對應燈號秒數，如果等於，將 recount 設為 1，否則 recount = 0
