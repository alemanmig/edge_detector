# Edge Detector

Diseño y verificación de un detector de flancos en RTL que genera pulsos de un ciclo de reloj.

## Objetivo

Implementar un detector de flancos que produzca:

- Un pulso en flanco de subida (`0→1`)
- Un pulso en flanco de bajada (`1→0`)

## Lógica de detección

La detección se basa en comparar la entrada actual `sig_in` contra su valor previo `sig_prev`:

```text
rise_pulse =  sig_in & ~sig_prev
fall_pulse = ~sig_in &  sig_prev
```

Donde `sig_prev` es el valor registrado de `sig_in` del ciclo anterior.

## Restricciones del diseño

- Pulso de un solo ciclo por cada transición detectada.
- Sin re-disparo mientras la entrada permanezca estable.
- En reset: `sig_prev = 0`.

## Comportamiento esperado

- Si `sig_in` cambia de `0` a `1`, `rise_pulse` se activa durante un ciclo.
- Si `sig_in` cambia de `1` a `0`, `fall_pulse` se activa durante un ciclo.
- Si `sig_in` no cambia, ambas salidas permanecen en `0`.
