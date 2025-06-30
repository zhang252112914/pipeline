- 对于前递逻辑的更改：
    - 由于beq可能需要提前计算，那么就需要前递一些可能依赖的寄存器

- pipeline_cpu、forwarding、hazard_detection都惊醒了修改