В коде реализована [Абелева песочная куча](https://en.wikipedia.org/wiki/Abelian_sandpile_model)

## Сборка и запуск
```bash
clang -O2 -Wall -Wextra start.c sim.c app.c -lSDL2 -o app
./app
```

## LLVM IR
```bash
clang -O2 -S -emit-llvm app.c -o app-opt.ll
```

app-opt.ll - IR симуляции (app.c), сгенерированный оптимизацией с -O2