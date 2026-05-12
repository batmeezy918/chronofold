#include <jni.h>
#include <string>
#include <vector>
#include <map>

struct WorkflowState {
    std::string current_state;
    std::vector<std::pair<std::string, std::string>> history; // op, state
};

static WorkflowState g_engine_state = {"ψ_0", {}};

extern "C"
JNIEXPORT jstring JNICALL
Java_com_apollo_MainActivity_runWorkflowTransition(JNIEnv* env, jobject, jstring state_in, jstring op_in) {
    const char* c_op = env->GetStringUTFChars(op_in, 0);

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

extern "C"
JNIEXPORT void JNICALL
Java_com_apollo_MainActivity_replayHistory(JNIEnv* env, jobject, jobjectArray ops, jobjectArray states) {
    g_engine_state.history.clear();
    int len = env->GetArrayLength(ops);
    for (int i = 0; i < len; i++) {
        jstring js_op = (jstring)env->GetObjectArrayElement(ops, i);
        jstring js_st = (jstring)env->GetObjectArrayElement(states, i);

        const char* c_op = env->GetStringUTFChars(js_op, 0);
        const char* c_st = env->GetStringUTFChars(js_st, 0);

        g_engine_state.history.push_back({c_op, c_st});

        env->ReleaseStringUTFChars(js_op, c_op);
        env->ReleaseStringUTFChars(js_st, c_st);
    }
    if (!g_engine_state.history.empty()) {
        g_engine_state.current_state = "ψ_{" + std::to_string(g_engine_state.history.size()) + "} [REPLAYED]";
    }
}
