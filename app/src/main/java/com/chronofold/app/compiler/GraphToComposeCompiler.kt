package com.chronofold.app.compiler

import android.content.Context
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

data class OperatorInfo(val id: String, val role: String)

class GraphToComposeCompiler(private val context: Context) {

    private var compiledOperators: List<OperatorInfo> = emptyList()

    fun compile(): List<OperatorInfo> {
        return try {
            val jsonString = context.assets.open("workflow_graph.json").bufferedReader().use { it.readText() }
            val root = Json.parseToJsonElement(jsonString).jsonObject
            val operators = root["operators"]?.jsonArray

            compiledOperators = operators?.map { op ->
                OperatorInfo(
                    id = op.jsonObject["id"]?.jsonPrimitive?.content ?: "Unknown",
                    role = op.jsonObject["role"]?.jsonPrimitive?.content ?: "Unknown"
                )
            } ?: emptyList()

            compiledOperators
        } catch (e: Exception) {
            emptyList()
        }
    }

    fun getOperators(): List<OperatorInfo> = compiledOperators
}
