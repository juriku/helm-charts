{{- define "base.rbac" -}}
{{- $root := . -}}

{{- if .Values.aggregationRule -}}
{{- range .Values.aggregationRule }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
aggregationRule:
  clusterRoleSelectors:
  - matchLabels:
  {{- with .matchLabels }}
      {{- toYaml . | trim | nindent 6 }}
  {{- end }}
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: {{ .name }}
rules: null
{{- end }}
{{- end }}

{{- if .Values.ClusterRole -}}
{{- range .Values.ClusterRole }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  {{- if .labels -}}
  {{- with .labels }}
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  {{- end }}
  name: {{ .name }}
{{- if .rules -}}
{{- with .rules }}
rules:
  {{- toYaml . | trim | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- if .Values.ClusterRoleBinding -}}
{{- range .Values.ClusterRoleBinding }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  {{- if .labels -}}
  labels:
  {{- with .labels }}
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  {{- end }}
  name: {{ .name }}
subjects:
{{- if .groups -}}
{{- range .groups }}
{{- $valueRange := pluck . $root.Values.Groups | first }}
{{- range $valueRange }}
- kind: User
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
{{- end }}
{{- if .serviceAccountGroups -}}
{{- range .serviceAccountGroups }}
{{- $valueRange := pluck . $root.Values.serviceAccountGroups | first }}
{{- range $valueRange }}
- kind: ServiceAccount
  name: {{ .name | trim | quote }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- if .kubeGroups -}}
{{- range .kubeGroups }}
- kind: Group
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
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
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  {{- if .labels -}}
  labels:
  {{- with .labels }}
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  {{- end }}
  name: {{ .name }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
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
{{- range .Values.RoleBinding }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  {{- if .labels -}}
  labels:
  {{- with .labels }}
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  {{- end }}
  name: {{ .name }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- end }}
subjects:
{{- if .groups -}}
{{- range .groups }}
{{- $valueRange := pluck . $root.Values.Groups | first }}
{{- range $valueRange }}
- kind: User
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
{{- end }}
{{- if .serviceAccountGroups -}}
{{- range .serviceAccountGroups }}
{{- $valueRange := pluck . $root.Values.serviceAccountGroups | first }}
{{- range $valueRange }}
- kind: ServiceAccount
  name: {{ .name | trim | quote }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- if .kubeGroups -}}
{{- range .kubeGroups }}
- kind: Group
  name: {{ . | trim | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}
roleRef:
{{- if .ClusterRoleName }}
  kind: ClusterRole
  name: {{ .ClusterRoleName }}
{{- else if .RoleName }}
  kind: Role
  name: {{ .RoleName }}
{{- end }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}

{{- if .Values.ServiceAccount -}}
{{- range .Values.ServiceAccount }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  {{- with .labels }}
  labels:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  {{- with .annotations }}
  annotations:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
  name: {{ .name }}
  {{- if .namespace }}
  namespace: {{ .namespace | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{- end }}