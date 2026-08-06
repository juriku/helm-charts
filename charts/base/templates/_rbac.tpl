{{/*
Render binding subjects. Takes a dict of "binding" (the ClusterRoleBinding or
RoleBinding entry) and "root".
*/}}
{{- define "base.rbacSubjects" -}}
{{- $binding := .binding -}}
{{- $root := .root -}}
{{- with $binding.subjects }}
{{ toYaml . | trim }}
{{- end }}
{{- range $binding.UserLists }}
{{- range pluck . $root.Values.RbacUserLists | first }}
- kind: User
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
{{- range $binding.GroupLists }}
{{- range pluck . $root.Values.RbacGroupLists | first }}
- kind: Group
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
{{- range $binding.serviceAccountGroups }}
{{- range pluck . $root.Values.serviceAccountGroups | first }}
- kind: ServiceAccount
  name: {{ .name | trim | quote }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- else if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
{{- end }}
{{- end }}
{{- range $binding.kubeGroups }}
- kind: Group
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}

{{- define "base.rbac" -}}
{{- $root := . -}}

{{- if .Values.ClusterRole -}}
{{- range .Values.ClusterRole }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  {{- with .annotations }}
  annotations:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
    {{- with .labels }}
    {{- toYaml . | trim | nindent 4 }}
    {{- end }}
  name: {{ .name }}
{{- with .aggregationRule }}
aggregationRule:
  {{- toYaml . | trim | nindent 2 }}
{{- end }}
{{- with .rules }}
rules:
  {{- toYaml . | trim | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{- if .Values.ClusterRoleBinding -}}
{{- range .Values.ClusterRoleBinding }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  {{- with .annotations }}
  annotations:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
    {{- with .labels }}
    {{- toYaml . | trim | nindent 4 }}
    {{- end }}
  name: {{ .name }}
{{- with include "base.rbacSubjects" (dict "binding" . "root" $root) }}
subjects:
{{ . }}
{{- end }}
roleRef:
  kind: ClusterRole
  name: {{ .ClusterRoleName }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}

{{- if .Values.Role -}}
{{- range .Values.Role }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  {{- with .annotations }}
  annotations:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
    {{- with .labels }}
    {{- toYaml . | trim | nindent 4 }}
    {{- end }}
  name: {{ .name }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- else if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
{{- if .rules -}}
{{- with .rules }}
rules:
  {{- toYaml . | trim | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- if .Values.RoleBinding -}}
{{- $root := . -}}
{{- $defaultNamespaces := .Values.defaultNamespaces }}
{{- range .Values.RoleBinding }}
{{- $coreRange := . -}}
{{- $rangeNamespaces := coalesce .namespaces (list .namespace) (list) }}
{{- $rangeNamespaces := ternary $defaultNamespaces $rangeNamespaces (.defaultNamespaces | default false) }}
{{- range $rangeNamespaces }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  {{- with $coreRange.annotations }}
  annotations:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
    {{- with $coreRange.labels }}
    {{- toYaml . | trim | nindent 4 }}
    {{- end }}
  name: {{ $coreRange.name }}
  {{- if . }}
  namespace: {{ . | quote }}
  {{- else if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
{{- with include "base.rbacSubjects" (dict "binding" $coreRange "root" $root) }}
subjects:
{{ . }}
{{- end }}
roleRef:
{{- if $coreRange.ClusterRoleName }}
  kind: ClusterRole
  name: {{ $coreRange.ClusterRoleName }}
{{- else if $coreRange.RoleName }}
  kind: Role
  name: {{ $coreRange.RoleName }}
{{- else }}
{{- fail (printf "RoleBinding %s needs either RoleName or ClusterRoleName" $coreRange.name) }}
{{- end }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
{{- end }}


{{- if .Values.ServiceAccount -}}
{{- range .Values.ServiceAccount }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    {{- include "base.labels" $root | trim | nindent 4 }}
    {{- with .labels }}
    {{- toYaml . | trim | nindent 4 }}
    {{- end }}
  {{- with .annotations }}
  annotations:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  name: {{ .name }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- else if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}