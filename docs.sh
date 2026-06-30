swift package --allow-writing-to-directory ./docs \
    generate-documentation \
    --target Resolver \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path Resolver \
    --output-path ./docs
