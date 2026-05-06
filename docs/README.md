# Edge Detector — Documentación de diseño

## Descripción general

El módulo `edge_detector` detecta transiciones en una señal digital y genera un **pulso de exactamente un ciclo de reloj** por cada transición:

- **Flanco ascendente** (`0 → 1`): activa `rise_pulse_o` durante un ciclo.
- **Flanco descendente** (`1 → 0`): activa `fall_pulse_o` durante un ciclo.

Mientras la señal permanece estable (`0` constante o `1` constante) no se genera ningún pulso. No hay re-disparo.

---

## Archivo RTL

```
rtl/edge_detector.sv
```

---

## Parámetros

| Parámetro   | Tipo  | Default | Descripción |
|-------------|-------|---------|-------------|
| `ResetPrev` | `bit` | `1'b0`  | Valor cargado en `sig_prev_q` al aplicar reset. Con `0` (default) no se genera pulso espurio al salir de reset, porque `sig_prev_q` y `sig_in_i` arrancan alineados a `0`. Cambiar a `1` si la señal de entrada se espera en alto justo después del reset. |

---

## Puertos

| Puerto         | Dirección | Tipo    | Descripción |
|----------------|-----------|---------|-------------|
| `clk_i`        | input     | `logic` | Reloj del sistema (sensible a flanco positivo). |
| `rst_ni`       | input     | `logic` | Reset asíncrono activo-bajo. Al valer `0` fuerza `sig_prev_q = ResetPrev`. |
| `sig_in_i`     | input     | `logic` | Señal a monitorear. |
| `rise_pulse_o` | output    | `logic` | Pulso de un ciclo en flanco ascendente (`0→1`). |
| `fall_pulse_o` | output    | `logic` | Pulso de un ciclo en flanco descendente (`1→0`). |

---

## Lógica interna

### Señal registrada

```
sig_prev_q  ←  sig_in_i   (capturado en cada posedge clk_i)
```

`sig_prev_q` almacena el valor de `sig_in_i` del ciclo anterior. Es el único elemento de estado del módulo.

### Generación de pulsos (combinacional)

```
rise_pulse_o =  sig_in_i & ~sig_prev_q
fall_pulse_o = ~sig_in_i &  sig_prev_q
```

Ambas expresiones son mutuamente excluyentes: nunca pueden ser `1` al mismo tiempo.

---

## Diagrama de tiempos

```
           ┌───┐       ┌───────┐   ┌─┐
clk_i   ───┘   └───────┘       └───┘ └──

              ┌───────────────┐
sig_in_i ─────┘               └─────────

sig_prev_q ──────┐               ┌──────
                 └───────────────┘

           ──────┐
rise_pulse_o     └──────────────────────
                               ┌─┐
fall_pulse_o ──────────────────┘ └──────
```

- `rise_pulse_o` sube **un ciclo** después del flanco ascendente de `sig_in_i` (es el ciclo donde `sig_prev_q` ya vale `0` pero `sig_in_i` vale `1`).
- `fall_pulse_o` sube **un ciclo** después del flanco descendente de `sig_in_i`.
- Ambos pulsos duran exactamente **un período de reloj**.

---

## Comportamiento en reset

Al afirmar `rst_ni = 0` (puede ocurrir en cualquier momento, es asíncrono):

```
sig_prev_q  ←  ResetPrev   (default: 0)
```

Con el default `ResetPrev = 0`:

- Si `sig_in_i` vale `0` al salir de reset → `rise_pulse_o = 0 & ~0 = 0`. Sin pulso. Correcto.
- Si `sig_in_i` vale `1` al salir de reset → `rise_pulse_o = 1 & ~0 = 1`. Se genera un pulso ascendente. Este comportamiento es **intencional**: el módulo interpreta la primera muestra en alto como una transición desde el estado de reset.

---

## Restricciones de diseño

| Restricción | Detalle |
|-------------|---------|
| Un pulso por transición | La lógica `AND/~AND` con el estado registrado garantiza que el pulso dure exactamente un ciclo. |
| Sin re-disparo | Mientras `sig_in_i` es estable, `sig_in_i == sig_prev_q`, por lo que ambas salidas son `0`. |
| Reset asíncrono | El bloque `always_ff` responde a `negedge rst_ni` independientemente del reloj. |
| Sin latches | Toda la lógica combinacional se implementa con `assign`; no hay `always_comb` con ramas incompletas. |

---

## Consideración: señales asíncronas

Si `sig_in_i` proviene de un dominio de reloj diferente o de un pin externo, existe riesgo de **metaestabilidad**. En ese caso se recomienda anteponer un sincronizador de dos flip-flops:

```
sig_in_async → [FF1] → [FF2] → sig_in_i (sincronizada) → edge_detector
```

El módulo `edge_detector` no incluye ese sincronizador; debe añadirse externamente.

---

## Convenciones de estilo

El RTL sigue la **lowRISC Verilog Coding Style Guide**:

| Elemento | Convención aplicada |
|----------|---------------------|
| Puertos de entrada | sufijo `_i` |
| Puertos de salida | sufijo `_o` |
| Reset activo-bajo | sufijo `_ni` |
| Señales registradas | sufijo `_q` |
| Parámetros | PascalCase |
| Lógica secuencial | `always_ff` |
| Lógica combinacional | `assign` continuo |
| Indentación | 2 espacios |
| Tipo de señal | `logic` (nunca `wire`/`reg`) |

---

## Ejemplo de instanciación

```systemverilog
edge_detector #(
  .ResetPrev (1'b0)
) u_edge_detector (
  .clk_i        (clk),
  .rst_ni       (rst_n),
  .sig_in_i     (button_sync),
  .rise_pulse_o (btn_press),
  .fall_pulse_o (btn_release)
);
```
