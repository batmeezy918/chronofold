package com.apollo

import android.app.Activity
import android.os.Bundle
import android.widget.TextView
import android.widget.LinearLayout
import android.widget.Button

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

        statusView = TextView(this).apply {
            text = "Ready."
        }
        layout.addView(statusView)

        Button(this).apply {
            text = "Execute Step (O_PHYS)"
            setOnClickListener {
                runWorkflowTransition("current", "O_PHYS")
                updateUI()
            }
        }.also { layout.addView(it) }

        Button(this).apply {
            text = "Rollback"
            setOnClickListener {
                rollback()
                updateUI()
            }
        }.also { layout.addView(it) }

        setContentView(layout)
        updateUI()
    }

    private fun updateUI() {
        statusView.text = getWorkflowGraph()
    }
}
