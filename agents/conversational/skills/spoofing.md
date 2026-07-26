# Skill: Spoofing

## Referencia legal
- Art. 212 LMV — manipulación de mercado mediante órdenes ficticias
- Art. 370 LMV — sanciones
- Circular Única de Casas de Bolsa (CUCB) — obligaciones de integridad de órdenes

## Qué es
Publicación de órdenes de compra o venta de gran volumen sin intención de ejecutarlas,
para mover artificialmente el precio del instrumento y luego cancelarlas una vez que
la operación beneficiaria se ejecutó al precio deseado.

## Mecánica del patrón
1. Se publican órdenes fantasma (gran volumen) en un lado del libro
2. El mercado reacciona moviendo el precio
3. Se ejecuta la operación beneficiaria al precio favorable
4. Se cancelan las órdenes fantasma

## Qué analizar
1. ¿Cuántas órdenes fantasma hubo y en cuántos segundos se cancelaron?
2. ¿Cuál fue el volumen de presión artificial vs. el volumen ejecutado?
3. ¿La operación beneficiaria se ejecutó en el lado opuesto al de las órdenes fantasma?
4. ¿El precio de la operación beneficiaria fue favorable respecto al precio de referencia?
5. ¿Hay patrón repetido en la misma jornada o en jornadas anteriores?
6. ¿El operador tiene historial de cancelaciones masivas?

## Señales que elevan la sospecha
- Órdenes canceladas en < 15 segundos promedio
- 3 o más órdenes fantasma en la misma jornada/instrumento
- Operación beneficiaria ejecutada inmediatamente después de las cancelaciones
- Precio beneficiario claramente mejor que el precio de referencia

## Conclusión esperada
Determinar si las cancelaciones son parte de una estrategia de manipulación
de precio o responden a cambios legítimos de condiciones de mercado.
