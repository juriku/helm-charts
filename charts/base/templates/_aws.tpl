{{- define "base.awsTargetGroupBindings" -}}
{{- $root := . }}
{{- range $index, $binding := .Values.targetGroupBindings }}
---
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  {{- if $binding.name }}
  name: {{ $binding.name }}
  {{- else if eq $index 0 }}
  name: {{ include "base.fullname" $root }}
  {{- else }}
  name: {{ printf "%s-%s" (include "base.fullname" $root) (toString (add $index 1)) }}
  {{- end }}
  {{- if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
spec:
  targetGroupARN: {{ $binding.targetGroupARN }}
  {{- with $binding.targetType }}
  targetType: {{ . }}
  {{- end }}
  serviceRef:
    name: {{ $binding.serviceRef.name | default ($root.Values.service.name | default (include "base.fullname" $root)) }}
    port: {{ $binding.serviceRef.port | default (include "base.servicePortDefaultNum" $root) }}
  {{- with $binding.networking }}
  networking:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "base.awsSecurityGroupPolicies" -}}
{{- $root := . }}
{{- range $index, $policy := .Values.securityGroupPolicies }}
---
apiVersion: vpcresources.k8s.aws/v1beta1
kind: SecurityGroupPolicy
metadata:
  {{- if $policy.name }}
  name: {{ $policy.name }}
  {{- else if eq $index 0 }}
  name: {{ include "base.fullname" $root }}
  {{- else }}
  name: {{ printf "%s-%s" (include "base.fullname" $root) (toString (add $index 1)) }}
  {{- end }}
  {{- if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
spec:
  {{- if $policy.podSelector }}
  podSelector:
    {{- toYaml $policy.podSelector | nindent 4 }}
  {{- else }}
  podSelector:
    matchLabels:
      {{- include "base.selectorLabels" $root | trim | nindent 6 }}
  {{- end }}
  securityGroups:
    groupIds:
      {{- toYaml $policy.securityGroups | nindent 6 }}
{{- end }}
{{- end }}

{{- define "base.awsIngressClassParams" -}}
{{- $root := . }}
{{- range $name, $params := .Values.ingressClassParams }}
---
apiVersion: elbv2.k8s.aws/v1beta1
kind: IngressClassParams
metadata:
  name: {{ $name }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
spec:
  {{- toYaml $params | nindent 2 }}
{{- end }}
{{- end }}
