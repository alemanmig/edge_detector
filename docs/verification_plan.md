# Plan de Verificación — Edge Detector

## 1. Propósito

Este documento define la estrategia de verificación para el módulo `edge_detector`. Su función es establecer qué aspectos del diseño deben verificarse, qué cobertura funcional se busca alcanzar, cuáles son las exclusiones del esfuerzo de verificación y qué criterios marcarán el cierre de la actividad.

El detalle operativo de ejecución, estímulos por caso y orden de corrida se documenta por separado en [test_plan.md](/Users/miguel/Documents/alemanmig/edge_detector/docs/test_plan.md:1).

## 2. Alcance

La verificación debe demostrar los siguientes comportamientos del DUT:

- Detección de flanco de subida (`0→1`).
- Detección de flanco de bajada (`1→0`).
- Generación de pulsos de exactamente un ciclo.
- Ausencia de re-disparo mientras la entrada permanezca estable.
- Inicialización correcta del estado previo en reset con `sig_prev = 0`.
- No solapamiento entre `rise_pulse_o` y `fall_pulse_o`.

## 3. Exclusiones

Los siguientes aspectos quedan fuera del alcance de esta verificación:

- Análisis de CDC o sincronización entre dominios de reloj.
- Comportamiento frente a metastabilidad en entradas asíncronas.
- Validación a nivel gate, temporización post-síntesis o cierre STA.
- Pruebas sobre variaciones de implementación física.

Se asume que `sig_in_i` está sincronizada al dominio de `clk_i`.

## 4. Enfoque de verificación

La estrategia de verificación será simulación RTL dirigida. El entorno de prueba deberá aplicar secuencias controladas sobre `sig_in_i` y comprobar el comportamiento de `rise_pulse_o` y `fall_pulse_o` ciclo por ciclo.

La verificación se apoyará en:

- Casos dirigidos para flancos de subida y bajada.
- Casos dirigidos para transiciones múltiples.
- Casos dirigidos para entrada estable.
- Casos dirigidos para reset e inicialización.
- Checks funcionales para ancho de pulso, no re-disparo y exclusión mutua de salidas.

## 5. Cobertura funcional propuesta

La cobertura funcional mínima a alcanzar es la siguiente:

- Cobertura de detección de flanco de subida.
- Cobertura de detección de flanco de bajada.
- Cobertura de pulsos de un solo ciclo.
- Cobertura de ausencia de re-disparo con entrada estable en `0`.
- Cobertura de ausencia de re-disparo con entrada estable en `1`.
- Cobertura de inicialización post-reset.
- Cobertura de alternancia entre flancos de subida y bajada.
- Cobertura de exclusión mutua entre `rise_pulse_o` y `fall_pulse_o`.

## 6. Mapa de cobertura a requisitos

| Requisito | Intención de verificación |
|-----------|----------------------------|
| `rise_pulse = sig_in & ~sig_prev` | Confirmar detección correcta de transición `0→1` |
| `fall_pulse = ~sig_in & sig_prev` | Confirmar detección correcta de transición `1→0` |
| Single-cycle pulse per detection | Verificar que cada pulso tenga ancho de un ciclo |
| No re-triggering while input holds steady | Verificar ausencia de pulsos repetidos en niveles estables |
| Reset: `sig_prev = 0` | Verificar inicialización del estado previo al liberar reset |

## 7. Riesgos de verificación

- El entorno actual de `verification/` parece provenir de otro diseño y debe alinearse al comportamiento real del `edge_detector`.
- Si no se implementan checks ciclo por ciclo, es fácil aceptar falsos positivos en secuencias cortas.
- El caso post-reset requiere una definición clara del instante exacto en que se espera el primer pulso para evitar ambigüedad entre reset y operación normal.

## 8. Criterio de cierre

La verificación se considerará cerrada cuando:

- Todos los requisitos funcionales del módulo tengan cobertura asociada.
- Todos los casos definidos en el [test_plan.md](/Users/miguel/Documents/alemanmig/edge_detector/docs/test_plan.md:1) hayan sido ejecutados.
- Todos los checks funcionales hayan pasado sin errores.
- No existan pulsos de más de un ciclo.
- No existan pulsos repetidos con entrada estable.
- No exista activación simultánea de `rise_pulse_o` y `fall_pulse_o`.

## 9. Entregables

- Testbench RTL alineado al DUT.
- Casos de prueba definidos y ejecutables.
- Registro de resultados por caso.
- Evidencia de cobertura funcional.
- Reporte final de cierre de verificación.
