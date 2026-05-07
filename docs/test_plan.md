# Test Plan — Edge Detector

## 1. Propósito

Este documento describe cómo se ejecutarán las pruebas del módulo `edge_detector`. Aquí se define el entorno de simulación, el flujo de ejecución, la lista de pruebas, los estímulos por caso, los checks operativos y la evidencia que debe recolectarse.

La estrategia general, cobertura y criterios de cierre globales se documentan en [verification_plan.md](/Users/miguel/Documents/alemanmig/edge_detector/docs/verification_plan.md:1).

## 2. Entorno de ejecución

Las pruebas se correrán sobre un testbench RTL con los siguientes componentes:

- Instancia del DUT `edge_detector`.
- Generador de reloj `clk_i`.
- Generación de reset `rst_ni`.
- Driver para aplicar valores de `sig_in_i`.
- Monitor para capturar `sig_in_i`, `rise_pulse_o` y `fall_pulse_o`.
- Checker para comparar resultados observados contra resultados esperados por ciclo.
- Log de resultados con estado `PASS` o `FAIL`.

## 3. Flujo general de ejecución

Cada prueba seguirá la secuencia:

1. Inicializar señales del testbench.
2. Aplicar reset al DUT.
3. Liberar reset.
4. Aplicar la secuencia de `sig_in_i` definida para el caso.
5. Muestrear salidas en cada ciclo de reloj.
6. Comparar resultados observados contra la expectativa del caso.
7. Registrar resultado final de la prueba.

La validación se hará ciclo por ciclo.

## 4. Checks operativos

Durante la ejecución de todos los casos, el checker debe validar:

- `rise_pulse_o` solo se activa en una transición `0→1`.
- `fall_pulse_o` solo se activa en una transición `1→0`.
- Cada pulso dura exactamente un ciclo.
- No hay pulsos repetidos cuando `sig_in_i` se mantiene estable.
- `rise_pulse_o` y `fall_pulse_o` no se activan al mismo tiempo.
- Durante reset no se aceptan pulsos válidos.

## 5. Casos de prueba

### TP-01 — Rising Edge

- Objetivo: validar detección de flanco de subida.
- Secuencia `sig_in_i`: `0, 0, 1, 1, 1`
- Esperado:
  - `rise_pulse_o = 1` en ciclo 2
  - `rise_pulse_o = 0` en ciclos `0, 1, 3, 4`
  - `fall_pulse_o = 0` en todos los ciclos

### TP-02 — Falling Edge

- Objetivo: validar detección de flanco de bajada.
- Secuencia `sig_in_i`: `1, 1, 0, 0, 0`
- Esperado:
  - `fall_pulse_o = 1` en ciclo 2
  - `fall_pulse_o = 0` en ciclos `0, 1, 3, 4`
  - `rise_pulse_o = 0` en todos los ciclos

### TP-03 — Multiple Edges

- Objetivo: validar comportamiento ante transiciones alternadas.
- Secuencia `sig_in_i`: `0, 1, 0, 1, 0`
- Esperado:
  - `rise_pulse_o = 1` en ciclos `1, 3`
  - `fall_pulse_o = 1` en ciclos `2, 4`
  - Ambas salidas en `0` en el resto de ciclos

### TP-04 — No Re-trigger

- Objetivo: validar ausencia de re-disparo con entrada estable.
- Secuencia `sig_in_i`: `0` durante 5 ciclos, luego `1` durante 5 ciclos
- Esperado:
  - Un solo `rise_pulse_o = 1` en el ciclo de transición
  - `rise_pulse_o = 0` en el resto del tramo estable en alto
  - `fall_pulse_o = 0` durante toda la prueba

### TP-05 — Reset

- Objetivo: validar comportamiento post-reset.
- Estímulo:
  - Aplicar reset con `sig_in_i = 1`
  - Liberar reset manteniendo `sig_in_i = 1`
- Esperado:
  - El estado previo parte de `0`
  - En el siguiente ciclo válido, `rise_pulse_o = 1`
  - `fall_pulse_o = 0`

## 6. Orden de ejecución

El orden recomendado es:

1. `TP-05 Reset`
2. `TP-01 Rising Edge`
3. `TP-02 Falling Edge`
4. `TP-03 Multiple Edges`
5. `TP-04 No Re-trigger`

## 7. Criterio Pass/Fail por prueba

Una prueba se marca como `PASS` cuando:

- La secuencia aplicada coincide con la planificada.
- Todas las salidas observadas coinciden con el comportamiento esperado por ciclo.
- No se detectan violaciones de ancho de pulso, re-disparo o solapamiento de salidas.

Una prueba se marca como `FAIL` cuando:

- Aparece un pulso en un ciclo no esperado.
- Falta un pulso esperado.
- Un pulso dura más de un ciclo.
- `rise_pulse_o` y `fall_pulse_o` se activan simultáneamente.

## 8. Evidencia a recolectar

Para cada prueba se debe conservar:

- Nombre del caso ejecutado.
- Secuencia aplicada sobre `sig_in_i`.
- Valores observados de `rise_pulse_o` y `fall_pulse_o` por ciclo.
- Resultado `PASS` o `FAIL`.
- Descripción de la discrepancia y ciclo de falla, si aplica.

Opcionalmente, puede conservarse forma de onda como respaldo visual.

## 9. Nota de implementación

El directorio `verification/` ya contiene una base de testbench, pero todavía debe ajustarse a las señales y checks específicos del `edge_detector`. Este documento define el comportamiento que dicho entorno debe ejecutar.
