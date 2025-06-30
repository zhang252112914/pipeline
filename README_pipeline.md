# 五级流水线CPU实现

## 概述

本项目在原有单周期CPU的基础上，实现了一个带有完整hazard处理功能的五级流水线CPU。

## 流水线阶段

1. **IF (Instruction Fetch)** - 取指阶段
   - 从指令存储器读取指令
   - 计算PC+4

2. **ID (Instruction Decode)** - 译码阶段  
   - 指令译码
   - 寄存器读取
   - 立即数扩展
   - 控制信号生成

3. **EX (Execute)** - 执行阶段
   - ALU运算
   - 分支目标地址计算
   - 分支条件判断

4. **MEM (Memory Access)** - 访存阶段
   - 数据存储器读写

5. **WB (Write Back)** - 写回阶段
   - 将结果写回寄存器

## 冒险处理

### 1. 数据冒险 (Data Hazards)
- **RAW (Read After Write)冒险**：通过前递(Forwarding)解决
- **前递路径**：
  - EX->EX：从EX/MEM寄存器前递到ALU输入
  - MEM->EX：从MEM/WB寄存器前递到ALU输入
- **Load-Use冒险**：通过插入停顿(Stall)解决

### 2. 控制冒险 (Control Hazards)  
- **分支冒险**：通过清空(Flush)流水线解决
- 分支在EX阶段判断，错误取指的指令被清空

### 3. 结构冒险 (Structural Hazards)
- 通过分离指令存储器和数据存储器避免

## 关键模块

### 1. pipeline_cpu.v
- 五级流水线CPU核心
- 包含所有流水线寄存器
- 实现前递逻辑

### 2. hazard_detection_unit.v  
- 冒险检测单元
- 检测Load-Use冒险并插入停顿
- 处理控制冒险的清空信号

### 3. forwarding_unit.v
- 前递单元
- 生成前递控制信号
- 解决大部分数据冒险

### 4. pipeline_sccomp.v
- 顶层模块
- 连接CPU与存储器

## 复用的原有模块

- **ctrl.v**: 控制单元
- **alu.v**: 算术逻辑单元  
- **RF.v**: 寄存器文件
- **EXT.v**: 立即数扩展单元
- **dm.v**: 数据存储器
- **im.v**: 指令存储器
