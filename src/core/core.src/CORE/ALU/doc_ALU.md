# ALU 算术逻辑单元
## 处理器中用于算术和逻辑运算的组合逻辑电路


|信号|位宽|功能|详解|
|---|---|---|---|
|i_data_1|32|第一个输入|输入ALU的第一操作数，作为减法的被减数、移位的原始数据
|i_data_2|32|第二个输入|输入ALU的第二操作数，作为减法的减数、移位的位数
|i_mode|4|ALU功能选择|具体功能见下表|
|o_data|32|输出|ALU的计算结果|

## ALU 中 i_mode 信号对应功能
<table style="text-align:center;">
    <tr>
        <td>i_mode[3]</td>
        <td colspan=5>0</td>
        <td colspan=5>1</td>
    </tr>
    <tr>
        <td>i_mode[2:1]</td>
        <td colspan=2>00</td>
        <td>10</td>
        <td>11</td>
        <td>01</td>
        <td>00</td>
        <td>10</td>
        <td>11</td>
        <td colspan=2>01</td>
    </tr>
    <tr>
        <td>i_mode[0]</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
    </tr>
    <tr>
        <td>function</td>
        <td>add</td>
        <td>sub</td>
        <td>slt</td>
        <td>sltu</td>
        <td>sll</td>
        <td>xor</td>
        <td>or</td>
        <td>and</td>
        <td>srl</td>
        <td>sra</td>
    </tr>
</table>

ALU接收两个操作数 **i_data_1** 和 **i_data_2** ，根据 **i_mode** 选择不同的运算方式，最终结果在 **o_data** 输出。注意整个ALU为组合逻辑电路。

## 内部实现
通过内部的加法器、逻辑门和桶形移位器实现计算，最终使用多路复用器选择需要的结果。