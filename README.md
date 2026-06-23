# Verilog Pipeline Register Project - 流水线寄存器项目

## 项目概述 (Project Overview)

本项目实现了一个通用的Verilog流水线寄存器模块，用于CPU或其他数字系统中的流水线数据传递。

## 文件说明 (File Description)

### 1. pipe_reg.v
**流水线寄存器模块实现**

模块功能：
- 可配置数据宽度（WIDTH 参数，默认32位）
- 支持复位（rst_n）：低电平有效，将输出清零
- 支持冲洗（flush）：清除流水线数据，输出置零
- 支持暂停（stall）：保持当前值不变，用于处理流水线冒泡
- 正常传输：在时钟上升沿将输入数据传递到输出

**模块接口：**
```verilog
module pipe_reg #(parameter WIDTH = 32) (
    input wire clk,              // 时钟信号
    input wire rst_n,            // 复位信号（低电平有效）
    input wire stall,            // 暂停信号（高电平有效）
    input wire flush,            // 冲洗信号（高电平有效）
    input wire [WIDTH-1:0] din,  // 数据输入
    output reg [WIDTH-1:0] dout  // 数据输出
);
```

### 2. pipe_reg_tb.v
**流水线寄存器测试平台**

包含9个完整的测试用例：
1. **复位验证**：验证rst_n复位功能
2. **正常数据传输**：验证无控制信号时的正常操作
3. **暂停验证**：验证stall=1时数据保持不变
4. **释放暂停**：验证stall释放后正常工作
5. **冲洗验证**：验证flush=1时立即清零
6. **冲洗后恢复**：验证flush释放后正常工作
7. **暂停和冲洗组合**：验证flush优先级高于stall
8. **运行中复位**：验证运行中复位的效果
9. **复位后恢复**：验证复位后正常功能恢复

## 设计特性 (Design Features)

### 时序控制逻辑
```verilog
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)           // 优先级1：复位
        dout <= 'd0;
    else if (flush)       // 优先级2：冲洗
        dout <= 'd0;
    else if (!stall)      // 优先级3：暂停（取反）
        dout <= din;      // 正常数据传输
    // else: stall时保持当前值
end
```

### 优先级说明
1. **复位最高优先级**：rst_n = 0 时，无条件清零
2. **冲洗次高优先级**：flush = 1 时，清零输出
3. **暂停最低优先级**：stall = 1 时，保持值不变
4. **正常模式**：无上述信号时，传输数据

## 应用场景 (Application Scenarios)

### CPU流水线设计
- IF/ID、ID/EX、EX/MEM、MEM/WB 寄存器
- 用于保存流水线阶段间的中间数据

### 数据流处理
- 数据通路中的缓冲寄存器
- 时序协调和数据对齐

### 流水线暂停机制
- 处理结构相关（Structural Hazard）
- 实现流水线冒泡（Pipeline Bubble）

## 测试方法 (Test Methods)

### 使用Vivado/ISim
```bash
# 编译设计文件
vlog pipe_reg.v
vlog pipe_reg_tb.v

# 运行仿真
vsim -c pipe_reg_tb -do "run all"
```

### 使用Modelsim
```bash
vlog pipe_reg.v
vlog pipe_reg_tb.v
vsim work.pipe_reg_tb
run all
```

### 使用开源工具（Icarus Verilog + GTKWave）
```bash
# 编译和运行
iverilog -o pipe_reg_tb.vvp pipe_reg.v pipe_reg_tb.v
vvp pipe_reg_tb.vvp

# 查看波形
gtkwave pipe_reg_tb.vcd
```

## 仿真结果验证 (Simulation Verification)

### 关键测试点
| 测试项 | 条件 | 预期结果 | 说明 |
|--------|------|---------|------|
| 复位 | rst_n=0 | dout=0 | 立即生效 |
| 正常传输 | stall=0, flush=0 | dout=din | 延迟1个周期 |
| 暂停 | stall=1 | dout不变 | 保持前一个值 |
| 冲洗 | flush=1 | dout=0 | 立即清零 |
| 优先级 | stall=1, flush=1 | dout=0 | flush优先 |

## 设计说明 (Design Explanation)

### "插入气泡"概念说明
- **气泡**：流水线中暂时没有有效数据的阶段
- **场景**：当检测到数据相关时，通过暂停前级流水线阶段，使后级流水线充满0或无效数据
- **实现**：通过flush信号将寄存器清零，dout的后继流水级收到0，可以视为无效数据
- **作用**：避免使用错误或未准备好的数据

### 异步复位的优势
- **快速响应**：不需要等待时钟边缘
- **紧急控制**：系统错误或异常时立即响应
- **设计规范**：遵循同步设计规范（异步复位，同步撤离）

### Stall和Flush的区别
- **Stall（暂停）**：保留当前数据，等待后续阶段就绪
- **Flush（冲洗）**：清除数据，产生流水线气泡，用于刷新流水线

## 核心设计路径

```
时钟边沿 → 优先级判断 → {复位 > 冲洗 > 暂停 > 正常传输}
              ↓
         - 复位：dout ≤ 0
         - 冲洗：dout ≤ 0
         - 暂停：dout保持不变
         - 正常：dout ≤ din
```

## 报告要求清单

- [x] Verilog代码文件（pipe_reg.v）
- [x] Testbench代码文件（pipe_reg_tb.v）
- [x] 模块功能说明
- [x] 设计原理解释
- [x] 仿真测试说明
- [x] 仿真结果验证
- [x] 异步复位优势说明
- [x] Stall和Flush区别说明
- [x] 数据流向说明
- [x] 优先级设计说明

## 注意事项 (Important Notes)

1. **时钟异步复位**：虽然复位是异步的，但撤离是同步的（遵循最佳实践）
2. **优先级设计**：flush优先于stall，确保流水线冲洗的有效性
3. **参数化设计**：WIDTH参数可根据需要调整，实现不同位宽的流水线寄存器
4. **可扩展性**：该设计可扩展为多级流水线结构

---

**项目创建日期**：2026-06-23  
**作者**：qzrjytl
