# Skill: Structuring (Fragmentación)

## Referencia legal
- Art. 17 LFPIORPI — obligación de reporte por umbral ($7,500 USD / ~$140,000 MXN aprox.)
- Art. 18 LFPIORPI — plazo de 60 días hábiles desde que el OPLE confirma la alerta
- Recomendación GAFI 20 — reporte de operaciones sospechosas

## Qué es
Fragmentación deliberada de operaciones para que ninguna supere individualmente
el umbral de reporte obligatorio, pero el acumulado sí lo supera.

## Casos que detecta el sistema
- Caso 1: mismo día, mismo instrumento — patrón más obvio, desviación estándar baja = alta sospecha
- Caso 2: varios días, mismo instrumento — fragmentación temporal
- Caso 3: mismo día, varios instrumentos — fragmentación por instrumento

## Qué analizar
1. ¿Cuántos fragmentos hay y en qué ventana de tiempo?
2. ¿La suma total supera el umbral de reporte?
3. ¿La desviación estándar de los importes es baja? (montos casi idénticos = intencional)
4. ¿El cliente tiene historial de este patrón en jornadas anteriores?
5. ¿Existe justificación económica razonable para operar así?
6. ¿El nivel de riesgo del cliente es consistente con este comportamiento?

## Señales que elevan la sospecha
- Montos casi idénticos entre fragmentos (desviación < $1,000 MXN)
- Cliente de alto riesgo o país de riesgo
- Mismo operador en todos los fragmentos
- Patrón repetido en días anteriores

## Conclusión esperada
Determinar si la fragmentación es intencional para evadir el umbral o tiene
justificación operativa legítima (ej. límites de la cuenta, instrucciones del cliente).
