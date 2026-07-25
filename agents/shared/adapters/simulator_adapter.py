from typing import Any
from .base_adapter import BaseAdapter


class BrokerAdapter(BaseAdapter):
    """Traduce el esquema legacy broker al esquema canónico surveillance.

    Mapeo de tablas:
        traders          → espejo_operadores
        contrapartes     → espejo_clientes
        contratos        → espejo_cuentas
        valores          → espejo_instrumentos
        transacciones    → espejo_operaciones
        instrucciones    → espejo_ordenes
        tenencias        → espejo_posiciones
        resumen_diario   → espejo_saldos_diarios
    """

    def to_operador(self, row: dict[str, Any]) -> dict[str, Any]:
        return {
            "id":             row["trader_id"],
            "clave_operador": row["clave_op"],
            "nombre":         row["nombre_completo"],
            "estado":         row["estatus"],
            "fecha_alta":     row["fecha_registro"],
        }

    def to_cliente(self, row: dict[str, Any]) -> dict[str, Any]:
        return {
            "id":          row["contraparte_id"],
            "nombre":      row["nombre_razon_social"],
            "tipo":        row["tipo_persona"],
            "rfc":         row["clave_fiscal"],
            "fecha_alta":  row["fecha_alta"],
            "pais":        row["pais_origen"],
            "nivel_riesgo": row["perfil_riesgo"],
            "estado":      row["estatus"],
        }

    def to_cuenta(self, row: dict[str, Any]) -> dict[str, Any]:
        return {
            "id":                     row["contrato_id"],
            "cliente_id":             row["contraparte_id"],
            "numero_cuenta":          row["num_contrato"],
            "tipo":                   row["modalidad"],
            "moneda":                 row["divisa"],
            "fecha_apertura":         row["fecha_apertura"],
            "fecha_ultimo_movimiento": row["ultimo_movimiento"],
            "estado":                 row["estatus"],
        }

    def to_instrumento(self, row: dict[str, Any]) -> dict[str, Any]:
        return {
            "id":                     row["valor_id"],
            "ticker":                 row["clave_cotizacion"],
            "nombre":                 row["razon_social"],
            "sector":                 row["sector_economico"],
            "mercado":                row["bolsa"],
            "tipo":                   row["tipo_valor"],
            "volumen_promedio_diario": row["vol_promedio"],
            "precio_referencia":      row["precio_cierre"],
            "estado":                 row["estatus"],
        }

    def to_operacion(self, row: dict[str, Any]) -> dict[str, Any]:
        return {
            "id":             row["folio"],
            "cuenta_id":      row["contrato_id"],
            "instrumento_id": row["valor_id"],
            "operador_id":    row["trader_id"],
            "tipo":           row["sentido"],
            "cantidad":       row["titulos"],
            "precio":         row["precio_ejec"],
            "monto_total":    row["importe"],
            "timestamp":      row["fecha_hora"],
            "fecha":          row["fecha_op"],
            "estado":         row["estatus"],
        }

    def to_orden(self, row: dict[str, Any]) -> dict[str, Any]:
        return {
            "id":                   row["instruccion_id"],
            "cuenta_id":            row["contrato_id"],
            "instrumento_id":       row["valor_id"],
            "operador_id":          row["trader_id"],
            "operacion_id":         row["folio_transaccion"],
            "tipo":                 row["sentido"],
            "cantidad":             row["titulos"],
            "precio":               row["precio_limite"],
            "timestamp_envio":      row["hora_envio"],
            "timestamp_cancelacion": row["hora_cancelacion"],
            "estado":               row["estatus"],
            "fecha":                row["fecha_op"],
        }

    def to_posicion(self, row: dict[str, Any]) -> dict[str, Any]:
        return {
            "id":              row["tenencia_id"],
            "cuenta_id":       row["contrato_id"],
            "instrumento_id":  row["valor_id"],
            "fecha":           row["fecha_valuacion"],
            "cantidad":        row["saldo_titulos"],
            "precio_promedio": row["costo_promedio"],
            "valor_mercado":   row["valuacion"],
        }

    def to_saldo_diario(self, row: dict[str, Any]) -> dict[str, Any]:
        return {
            "id":              row["resumen_id"],
            "cuenta_id":       row["contrato_id"],
            "fecha":           row["fecha_corte"],
            "saldo_efectivo":  row["saldo_disponible"],
            "valor_portafolio": row["valuacion_cartera"],
            "total":           row["patrimonio"],
        }
