package com.apollo

import android.app.Activity
import android.os.Bundle
import android.widget.TextView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.Button
import android.widget.EditText
import android.app.AlertDialog

class MainActivity : Activity() {

    companion object {
        init {
            System.loadLibrary("apollo")
        }
    }

    external fun runWorkflowTransition(state: String, operator: String): String
    external fun getWorkflowGraph(): String
    external fun rollback()

    private lateinit var statusView: TextView

    override fun onCreate(b: Bundle?) {
        super.onCreate(b)

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
        }

        val header = TextView(this).apply {
            text = "Chronofold_X: Sovereign DAG IDE"
            textSize = 20f
            setPadding(20, 20, 20, 20)
        }
        layout.addView(header)

        val btnLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
        }

        Button(this).apply {
            text = "Add Node"
            setOnClickListener { showAddNodeDialog() }
        }.also { btnLayout.addView(it) }

        Button(this).apply {
            text = "Import YAML"
            setOnClickListener { /* TODO */ }
        }.also { btnLayout.addView(it) }

        Button(this).apply {
            text = "Build APK"
            setOnClickListener { /* TODO */ }
        }.also { btnLayout.addView(it) }

        layout.addView(btnLayout)

        statusView = TextView(this).apply {
            text = "Ready."
            setPadding(20, 20, 20, 20)
        }

        val scroll = ScrollView(this).apply {
            addView(statusView)
        }
        layout.addView(scroll, LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            0, 1f
        ))

        setContentView(layout)
        updateUI()
    }

    private fun showAddNodeDialog() {
        val input = EditText(this)
        AlertDialog.Builder(this)
            .setTitle("Insert Node")
            .setView(input)
            .setPositiveButton("OK") { _, _ ->
                runWorkflowTransition("current", "ADD_NODE_${input.text}")
                updateUI()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun updateUI() {
        statusView.text = getWorkflowGraph()
    }
}
