#include <jni.h>
#include <string>
#include <vector>
#include <map>

// Deterministic Workflow Engine State
struct WorkflowState {
    std::string current_state;
    std::vector<std::pair<std::string, std::string>> history; // op, state
};

static WorkflowState g_engine_state = {"ψ_0", {}};

extern "C"
JNIEXPORT jstring JNICALL
Java_com_apollo_MainActivity_runWorkflowTransition(JNIEnv* env, jobject, jstring state_in, jstring op_in) {
    const char* c_op = env->GetStringUTFChars(op_in, 0);

    // Transition: ψ_{k+1} = O_{π*}(ψ_k)
    std::string op(c_op);
    std::string new_state = "ψ_{" + std::to_string(g_engine_state.history.size() + 1) + "} [" + op + "]";

    g_engine_state.history.push_back({op, g_engine_state.current_state});
    g_engine_state.current_state = new_state;

    env->ReleaseStringUTFChars(op_in, c_op);
    return env->NewStringUTF(new_state.c_str());
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_apollo_MainActivity_getWorkflowGraph(JNIEnv* env, jobject) {
    std::string graph = "{\"history_count\": " + std::to_string(g_engine_state.history.size()) +
                        ", \"current\": \"" + g_engine_state.current_state + "\"}";
    return env->NewStringUTF(graph.c_str());
}

extern "C"
JNIEXPORT void JNICALL
Java_com_apollo_MainActivity_rollback(JNIEnv* env, jobject) {
    if (!g_engine_state.history.empty()) {
        auto last = g_engine_state.history.back();
        g_engine_state.current_state = last.second;
        g_engine_state.history.pop_back();
    }
}
