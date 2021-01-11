interface QueueItEngine {
    run(customerId: string,
        eventOrAliasId: string,
        layoutName?: string,
        language?: string,
        clearCache?: boolean,
        successCallback?: Function): void

    enableTesting(value: boolean): void
}
