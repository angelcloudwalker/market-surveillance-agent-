# Skill: Wash Trading

## Referencia legal
- Art. 212 LMV — manipulación de mercado
- Art. 370 LMV — sanciones (multa + inhabilitación)
- Recomendación GAFI 6 — personas políticamente expuestas y control de cuentas

## Qué es
Compra y venta del mismo instrumento entre cuentas controladas por la misma
entidad, creando volumen artificial sin cambio económico real. El objetivo es
inflar el volumen aparente del instrumento o generar comisiones artificiales.

## Casos que detecta el sistema
- Caso 1: mismo cliente, mismo operador, precio y cantidad exactos
- Caso 2: mismo cliente, diferente operador, precio y cantidad exactos
- Caso 3: mismo cliente, precio similar (±0.5%), cantidad similar (±5%)

## Casos pendientes (requieren análisis del OPLE)
- Caso 4: diferente cliente, mismo operador — posible coordinación implícita
- Caso 5: diferente cliente, diferente operador, precios cruzados

## Qué analizar
1. ¿Las cuentas involucradas pertenecen al mismo cliente o grupo económico?
2. ¿Cuántos segundos de diferencia entre la venta y la compra? (< 60s = muy sospechoso)
3. ¿Qué porcentaje del volumen promedio diario representa la operación?
4. ¿Hay beneficio económico real o solo movimiento circular?
5. ¿El operador participó en ambos lados de la operación?
6. ¿Existe patrón histórico de operaciones similares entre estas cuentas?

## Señales que elevan la sospecha
- Diferencia de segundos < 60 entre venta y compra
- Volumen > 20% del promedio diario del instrumento
- Precio exactamente igual en ambas operaciones
- Mismo operador en compra y venta
- Múltiples pares en la misma jornada

## Conclusión esperada
Determinar si existe coordinación intencional entre cuentas para crear
volumen artificial, o si las operaciones tienen justificación de mercado.
