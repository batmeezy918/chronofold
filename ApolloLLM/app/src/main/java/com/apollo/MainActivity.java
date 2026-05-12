package com.apollo;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
import android.widget.LinearLayout;
import android.widget.Button;
import android.content.ContentValues;
import android.database.sqlite.SQLiteDatabase;

public class MainActivity extends Activity {

    static {
        System.loadLibrary("apollo");
    }

    public native String runWorkflowTransition(String state, String operator);
    public native String getWorkflowGraph();
    public native void rollback();

    private TextView statusView;
    private DatabaseHelper dbHelper;

    @Override
    protected void onCreate(Bundle b) {
        super.onCreate(b);
        dbHelper = new DatabaseHelper(this);

        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);

        statusView = new TextView(this);
        statusView.setText("Ready.");
        layout.addView(statusView);

        Button btnStep = new Button(this);
        btnStep.setText("Execute Step (O_PHYS)");
        btnStep.setOnClickListener(v -> {
            String newState = runWorkflowTransition("current", "O_PHYS");
            persistTransition("O_PHYS", newState);
            updateUI();
        });
        layout.addView(btnStep);

        Button btnRollback = new Button(this);
        btnRollback.setText("Rollback");
        btnRollback.setOnClickListener(v -> {
            rollback();
            updateUI();
        });
        layout.addView(btnRollback);

        setContentView(layout);
        updateUI();
    }

    private void persistTransition(String op, String state) {
        SQLiteDatabase db = dbHelper.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put("operator", op);
        values.put("state", state);
        db.insert("workflow_state", null, values);
    }

    private void updateUI() {
        statusView.setText(getWorkflowGraph());
    }
}
