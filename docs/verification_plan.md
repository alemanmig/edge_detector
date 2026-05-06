# Plan de Verificación — Edge Detector

## 1. Objetivo

Verificar que el módulo `edge_detector` detecta correctamente flancos de subida y bajada en `sig_in`, y que genera pulsos de exactamente un ciclo en `rise_pulse` y `fall_pulse`, cumpliendo restricciones de no re-disparo y comportamiento correcto en reset.

## 2. Alcance

La verificación cubre:

- Detección de flanco de subida (`0→1`).
- Detección de flanco de bajada (`1→0`).
- Detección de múltiples transiciones en secuencias cortas.
- Comportamiento sin transiciones (entrada estable).
- Inicialización por reset con `sig_prev = 0`.

No cubre sincronización CDC; se asume `sig_in` estable en dominio de `clk_i`.

## 3. Especificación funcional bajo prueba

- Entrada: `sig_in` (1 bit), señal a monitorear.
- Salidas:
  - `rise_pulse` (1 bit): pulso alto de un ciclo en flanco de subida.
  - `fall_pulse` (1 bit): pulso alto de un ciclo en flanco de bajada.
- Registro interno:
  - `sig_prev`: almacena el valor previo de `sig_in` y se actualiza cada ciclo.
- Condiciones de detección:
  - Flanco de subida: `sig_in = 1` y `sig_prev = 0`.
  - Flanco de bajada: `sig_in = 0` y `sig_prev = 1`.

## 4. Criterios de aceptación

1. Cada transición válida genera exactamente un pulso de un ciclo.
2. No hay pulsos repetidos mientras `sig_in` permanece constante.
3. `rise_pulse` y `fall_pulse` no deben activarse simultáneamente.
4. Después de reset, `sig_prev` debe inicializarse en `0`.
5. No se generan pulsos durante reset.

## 5. Casos de prueba (matriz)

### TC-01 — Rising Edge

- Secuencia `sig_in`: `0, 0, 1, 1, 1`
- Resultado esperado:
  - `rise_pulse = 1` en ciclo 2 (transición `0→1`)
  - `rise_pulse = 0` en ciclos `0, 1, 3, 4`
  - `fall_pulse = 0` en todos los ciclos
- Cobertura objetivo: detección de flanco de subida + pulso único.

### TC-02 — Falling Edge

- Secuencia `sig_in`: `1, 1, 0, 0, 0`
- Resultado esperado:
  - `fall_pulse = 1` en ciclo 2 (transición `1→0`)
  - `fall_pulse = 0` en ciclos `0, 1, 3, 4`
  - `rise_pulse = 0` en todos los ciclos
- Cobertura objetivo: detección de flanco de bajada + pulso único.

### TC-03 — Multiple Edges

- Secuencia `sig_in`: `0, 1, 0, 1, 0`
- Resultado esperado:
  - `rise_pulse = 1` en ciclos `1, 3`
  - `fall_pulse = 1` en ciclos `2, 4`
  - Ambos pulsos en `0` en los demás ciclos
- Cobertura objetivo: alternancia de flancos y no solapamiento de pulsos.

### TC-04 — No Edges (Entrada estable por tramos)

- Secuencia `sig_in`: `0` por 5 ciclos, luego `1` por 5 ciclos
- Resultado esperado:
  - Un solo `rise_pulse = 1` en el ciclo de transición `0→1`
  - Sin pulsos repetidos durante los 5 ciclos en alto estable
  - `fall_pulse = 0` en toda la secuencia
- Cobertura objetivo: no re-disparo con entrada estable.

### TC-05 — Reset

- Estímulo:
  - Afirmar reset con `sig_in = 1`
  - Liberar reset manteniendo `sig_in = 1`
- Resultado esperado:
  - `sig_prev = 0` después de reset
  - En el siguiente ciclo válido: `rise_pulse = 1` (detección `0→1` desde estado de reset)
  - `fall_pulse = 0` durante este escenario
- Cobertura objetivo: inicialización y primer flanco post-reset.

## 6. Trazabilidad de restricciones

- Pulso de un ciclo por detección:
  - Cubierto por `TC-01`, `TC-02`, `TC-03`, `TC-04`.
- Sin re-disparo con entrada estable:
  - Cubierto por `TC-04`.
- Reset con `sig_prev = 0`:
  - Cubierto por `TC-05`.

## 7. Métricas mínimas de cierre

- 100% de casos de prueba ejecutados y aprobados (`5/5`).
- 0 fallas en checks de ancho de pulso y no re-disparo.
- 0 activaciones simultáneas de `rise_pulse` y `fall_pulse`.

## 8. Entregables de verificación

- Testbench con generación de reloj/reset y aplicación de secuencias.
- Registro de resultados por ciclo para cada caso.
- Reporte final con estado Pass/Fail por caso y resumen de cobertura funcional.
