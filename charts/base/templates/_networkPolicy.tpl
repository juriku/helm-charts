{{- define "base.networkPolicy" -}}
{{- $root := . }}
{{- range $index, $policy := .Values.networkPolicies }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  {{- if $policy.name }}
  name: {{ $policy.name }}
  {{- else if eq $index 0 }}
  name: {{ include "base.fullname" $root }}
  {{- else }}
  name: {{ printf "%s-%s" (include "base.fullname" $root) (toString (add $index 1)) }}
  {{- end }}
  {{- if $policy.namespace }}
  namespace: {{ $policy.namespace }}
  {{- else if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.labels" $root | trim | nindent 4 }}
  {{- with $policy.annotations }}
  annotations:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
spec:
  {{- if hasKey $policy "podSelector" }}
  podSelector:
    {{- toYaml $policy.podSelector | nindent 4 }}
  {{- else }}
  podSelector:
    matchLabels:
      {{- include "base.selectorLabels" $root | trim | nindent 6 }}
  {{- end }}
  {{- if $policy.policyTypes }}
  policyTypes:
    {{- toYaml $policy.policyTypes | nindent 4 }}
  {{- else if or $policy.ingress $policy.egress }}
  policyTypes:
    {{- if $policy.ingress }}
    - Ingress
    {{- end }}
    {{- if $policy.egress }}
    - Egress
    {{- end }}
  {{- end }}
  {{- with $policy.ingress }}
  ingress:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $policy.egress }}
  egress:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
