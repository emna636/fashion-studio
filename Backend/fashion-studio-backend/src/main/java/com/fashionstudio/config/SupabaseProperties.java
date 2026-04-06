package com.fashionstudio.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "supabase")
public record SupabaseProperties(
		String url,
		String anonKey
) {
	public String restUrl() {
		if (url == null || url.isBlank()) {
			return null;
		}
		return url.endsWith("/") ? (url + "rest/v1") : (url + "/rest/v1");
	}
}
