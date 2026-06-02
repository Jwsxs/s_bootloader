# BOOTLOADER

A premissa de um bootloader é literalmente, do inglês, "o que carrega a inicialização".

Esse simples projetinho foi feito em pensamento **BIOS Legacy**, e não UEFI mais recente, motivo será explicado.

### Etapas
Basicamente, ao apertar o botão de ligar,
1. BIOS chama POST ( Power-On Self Test );
    1. POST verifica integridade dos componentes, garantindo que **todos os componentes de hardware essenciais estejam funcionando corretamente**.
    2. Verifica: **Teste de memória RAM**, verificando **conectividade**, **integridade** e **capacidade**, se está funcional, e os inicia;
    3. Verifica: **Teste de I/O**, verificando dispositivos conectados em portas de **entrada** e **saída**, se estão funcionais e os inicia;
    4. Verifica: **Teste de Vídeo**, verificando **saída gráfica**, se está funcional, e o inicia;
    5. Verifica: **Teste de armazenamento**, verificando **HD's** e **SSD's**, se estão funcionais, e os inicia;
2. Caso de sucesso, chama MBR, verificando os primeiros **512 bytes** do disco;
    1. MBR (Master Boot Record), o **bootloader**.
    2. 512 bytes por questão histórica, mantendo os últimos dois bytes (o último word), como `55aa`, sendo a **assinatura de que é boot**.
3. Através do MBR, se usa `interruptions` (int) da BIOS para  se comunicar com o hardware, carregando algumas funções necessárias.
    1. Se utiliza destas pois o kernel ainda não está carregado, logo, `syscalls` não fazem sentido.

### Motivo da BIOS
O motivo da escolha BIOS, e não UEFI, consta a partir do momento em que a BIOS é melhor documentada.

Ela inicia no **real-mode**, rodando a 16-bits por compatibilidade com o processador 8086.

Assim, sendo necessário o uso de registradores de 16-bits, como `AH`, `AL`, ...,.

# CÓDIGO

Inicialmente, como dito, é necessário que o assimilador saiba que estamos mexendo com **16-bits**, evitando carregar algo de maior capacidade.

- GAS (**G**NU **AS**SEMBLER)
``` gas
.code16 # colocado no topo do código, primeira linha de preferência
```
- NASM (**N**ETWIDE **AS**SEMBLER)
``` nasm
BITS 16
```

<sub>Por questão de sanidade, vou mostrar o código todo para GAS, com sintaxe AT&T</sub>
---

Como todo programa básico, precisamos setar nossa `int main()` como global.

No caso, puxamos da `_start`

```gas
.globl _start

_start:
    # nosso código
```

Vale notar que deve ser a primeira função a ser escrita. ou seja, em sequência:
``` gas
1. .code16
2. .globl _start
3. _start:
4.      # código
...
```

---

Ao final, devemos completar nossos 512 bytes com toda a função:
```
# .fill repeat, size, value
.fill 510-(.-_start), 1, 0
```
Setando, até 510, a partir do tamanho de `_start`, como `0`

E os últimos 2 bytes ( WORD ), com nossa **assinatura** de bootloader.
``` gas
.byte 0x55
.byte 0xaa
```
