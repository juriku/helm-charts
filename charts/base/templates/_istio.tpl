{{- define "base.istioVirtualServices" -}}
{{- $root := . }}
{{- range $index, $vs := .Values.istioVirtualServices }}
---
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  {{- if $vs.name }}
  name: {{ $vs.name }}
  {{- else if eq $index 0 }}
  name: {{ include "base.fullname" $root }}
  {{- else }}
  name: {{ printf "%s-%s" (include "base.fullname" $root) (toString (add $index 1)) }}
  {{- end }}
  {{- if $vs.namespace }}
  namespace: {{ $vs.namespace }}
  {{- else if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
spec:
  {{- with $vs.hosts }}
  hosts:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $vs.gateways }}
  gateways:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $vs.http }}
  http:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $vs.tcp }}
  tcp:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $vs.tls }}
  tls:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "base.istioDestinationRules" -}}
{{- $root := . }}
{{- range $index, $dr := .Values.istioDestinationRules }}
---
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  {{- if $dr.name }}
  name: {{ $dr.name }}
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
  host: {{ $dr.host | default (include "base.fullname" $root) }}
  {{- with $dr.trafficPolicy }}
  trafficPolicy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $dr.subsets }}
  subsets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "base.istioGateways" -}}
{{- $root := . }}
{{- range $index, $gw := .Values.istioGateways }}
---
apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  {{- if $gw.name }}
  name: {{ $gw.name }}
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
  selector:
    {{- toYaml ($gw.selector | default (dict "istio" "ingressgateway")) | nindent 4 }}
  servers:
    {{- toYaml $gw.servers | nindent 4 }}
{{- end }}
{{- end }}

{{- define "base.istioPolicies" -}}
{{- $root := . }}
{{- with .Values.istioPeerAuthentication }}
---
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: {{ include "base.fullname" $root }}
  {{- if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
spec:
  {{- if .selector }}
  selector:
    {{- toYaml .selector | nindent 4 }}
  {{- else }}
  selector:
    matchLabels:
      {{- include "base.selectorLabels" $root | trim | nindent 6 }}
  {{- end }}
  mtls:
    mode: {{ .mode | default "STRICT" }}
{{- end }}
{{- range $index, $policy := .Values.istioAuthorizationPolicies }}
---
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
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
  {{- if $policy.selector }}
  selector:
    {{- toYaml $policy.selector | nindent 4 }}
  {{- else }}
  selector:
    matchLabels:
      {{- include "base.selectorLabels" $root | trim | nindent 6 }}
  {{- end }}
  {{- with $policy.action }}
  action: {{ . }}
  {{- end }}
  {{- with $policy.rules }}
  rules:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
