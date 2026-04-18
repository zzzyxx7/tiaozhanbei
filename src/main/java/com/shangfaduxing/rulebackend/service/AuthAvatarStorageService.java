package com.shangfaduxing.rulebackend.service;

import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import com.shangfaduxing.rulebackend.config.RuleAuthAvatarProperties;
import com.shangfaduxing.rulebackend.config.RuleAliOssProperties;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class AuthAvatarStorageService {

    private static final Set<String> ALLOWED_EXT = Set.of(".jpg", ".jpeg", ".png", ".webp", ".gif");
    private final RuleAuthAvatarProperties props;
    private final RuleAliOssProperties aliOssProperties;

    public AuthAvatarStorageService(RuleAuthAvatarProperties props, RuleAliOssProperties aliOssProperties) {
        this.props = props;
        this.aliOssProperties = aliOssProperties;
    }

    public String storeAvatarAndBuildUrl(MultipartFile file, HttpServletRequest request) throws IOException {
        validate(file);
        if (aliOssProperties.isConfigured()) {
            return uploadToAliOss(file);
        }
        String ext = resolveExt(file);
        String filename = UUID.randomUUID() + ext;
        Path dir = Paths.get(props.getStorageDir()).toAbsolutePath().normalize();
        Files.createDirectories(dir);
        Path target = dir.resolve(filename);
        file.transferTo(target);
        return buildPublicUrl(filename, request);
    }

    public Resource loadAvatar(String filename) {
        validateFilename(filename);
        Path path = Paths.get(props.getStorageDir()).toAbsolutePath().normalize().resolve(filename);
        if (!Files.exists(path) || !Files.isRegularFile(path)) {
            return null;
        }
        return new FileSystemResource(path);
    }

    public MediaType detectMediaType(String filename) {
        String lower = filename.toLowerCase(Locale.ROOT);
        if (lower.endsWith(".png")) return MediaType.IMAGE_PNG;
        if (lower.endsWith(".gif")) return MediaType.IMAGE_GIF;
        if (lower.endsWith(".webp")) return MediaType.parseMediaType("image/webp");
        return MediaType.IMAGE_JPEG;
    }

    private void validate(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("头像文件不能为空");
        }
        long maxBytes = (long) props.getMaxSizeMb() * 1024 * 1024;
        if (file.getSize() > maxBytes) {
            throw new IllegalArgumentException("头像文件过大，最大 " + props.getMaxSizeMb() + "MB");
        }
        String ct = file.getContentType();
        if (ct == null || !ct.toLowerCase(Locale.ROOT).startsWith("image/")) {
            throw new IllegalArgumentException("头像仅支持图片格式");
        }
    }

    private String resolveExt(MultipartFile file) {
        String name = file.getOriginalFilename();
        if (name != null) {
            int idx = name.lastIndexOf('.');
            if (idx >= 0 && idx < name.length() - 1) {
                String ext = name.substring(idx).toLowerCase(Locale.ROOT);
                if (ALLOWED_EXT.contains(ext)) {
                    return ext;
                }
            }
        }
        String ct = file.getContentType() == null ? "" : file.getContentType().toLowerCase(Locale.ROOT);
        return switch (ct) {
            case "image/png" -> ".png";
            case "image/gif" -> ".gif";
            case "image/webp" -> ".webp";
            case "image/jpg", "image/jpeg" -> ".jpg";
            default -> throw new IllegalArgumentException("头像图片格式不支持，仅支持 jpg/jpeg/png/webp/gif");
        };
    }

    private String buildPublicUrl(String filename, HttpServletRequest request) {
        String base = props.getPublicBaseUrl();
        if (base != null && !base.isBlank()) {
            String normalized = base.endsWith("/") ? base.substring(0, base.length() - 1) : base;
            return normalized + "/" + filename;
        }
        String host = request.getServerName();
        int port = request.getServerPort();
        String scheme = request.getScheme();
        String origin = ("http".equalsIgnoreCase(scheme) && port == 80)
                || ("https".equalsIgnoreCase(scheme) && port == 443)
                ? scheme + "://" + host
                : scheme + "://" + host + ":" + port;
        return origin + "/api/rule/auth/avatar/" + filename;
    }

    private String uploadToAliOss(MultipartFile file) throws IOException {
        String ext = resolveExt(file);
        LocalDate today = LocalDate.now();
        String objectName = String.format(
                "avatars/%d/%02d/%02d/%s%s",
                today.getYear(),
                today.getMonthValue(),
                today.getDayOfMonth(),
                UUID.randomUUID().toString().replace("-", ""),
                ext
        );

        OSS ossClient = null;
        try {
            ossClient = new OSSClientBuilder().build(
                    aliOssProperties.getEndpoint(),
                    aliOssProperties.getAccessKeyId(),
                    aliOssProperties.getAccessKeySecret()
            );
            ossClient.putObject(
                    aliOssProperties.getBucketName(),
                    objectName,
                    file.getInputStream()
            );
            return String.format(
                    "https://%s.%s/%s",
                    aliOssProperties.getBucketName(),
                    aliOssProperties.getEndpoint(),
                    objectName
            );
        } catch (Exception e) {
            throw new IllegalStateException("上传 OSS 失败: " + e.getMessage(), e);
        } finally {
            if (ossClient != null) {
                ossClient.shutdown();
            }
        }
    }

    private void validateFilename(String filename) {
        if (filename == null || filename.isBlank() || !filename.matches("[A-Za-z0-9._-]+")) {
            throw new IllegalArgumentException("非法文件名");
        }
    }
}
